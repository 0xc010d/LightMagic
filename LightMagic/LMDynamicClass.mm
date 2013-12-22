#import <objc/runtime.h>
#import <objc/message.h>
#import "LMDynamicClass.h"
#import "LMProperty.h"
#import "LMCache.h"

static const char *kRootClassName = "NSObject";
static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

static void class_swizzleClassMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation);
static void class_swizzleInstanceMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation);

static id swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone);
static id dynamicGetter(id self, SEL _cmd);
static id forwardingGetter(id self, SEL _cmd);
static void dynamicDealloc(id self, SEL  __unused _cmd);
static void swizzledDealloc(id self, SEL __unused _cmd);

@interface NSObject (LMSelector)

+ (instancetype)allocWithZone_:(NSZone *)zone;
- (void)dealloc_;

@end

@implementation LMDynamicClass {
    Class _counterpart;
    NSSet *_properties;
    Class _clazz;
}

+ (void)initialize {
    kRootClass = objc_getClass(kRootClassName);
    kSuffixLength = strlen(kSuffix);
}

- (instancetype)initForClass:(Class)clazz properties:(NSSet *)properties {
    self = [super init];
    _counterpart = clazz;
    _properties = properties;
    return self;
}

- (void)createAndInject {
    const char *prefix = class_getName(_counterpart);
    size_t nameLength = strlen(prefix);
    size_t classNameLength = nameLength + kSuffixLength;
    char name[classNameLength + 1];
    sprintf(name, "%s%s", prefix, kSuffix);
    _clazz = objc_allocateClassPair(kRootClass, (const char *)name, 0);

    [self addAndInjectProperties];
    objc_registerClassPair(_clazz);

    [self swizzleAlloc];
    [self swizzleDealloc];

    [self addDealloc];

    LMCache::getInstance().dynamicClasses[_counterpart] = _clazz;
}

- (void)addAndInjectProperties {
    for (LMProperty *property in _properties) {
        [self addPropertyWithClass:property.clazz getter:property.getter];
        [self forwardGetter:property.getter];
    }
}

- (void)swizzleAlloc {
    class_swizzleClassMethodWithImplementation(_counterpart, @selector(allocWithZone:), @selector(allocWithZone_:), (IMP)swizzledAllocWithZone);
}

- (void)swizzleDealloc {
    class_swizzleInstanceMethodWithImplementation(_counterpart, @selector(dealloc), @selector(dealloc_), (IMP)swizzledDealloc);
}

- (void)addDealloc {
    class_addMethod(_clazz, @selector(dealloc), (IMP)dynamicDealloc, "v@:");
}

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector {
    const char *name = sel_getName(selector);
    NSUInteger size, align;
    const char *encoding = @encode(id);
    NSGetSizeAndAlignment(encoding, &size, &align);
    class_addIvar(_clazz, name, size, (uint8_t)align, encoding);

    const char *className = class_getName(clazz);
    char type[strlen(className + 4)];
    sprintf(type, "@\"%s\"", className);
    objc_property_attribute_t attributes[] = {"T", type};
    class_addProperty(_clazz, name, attributes, 1);

    class_addMethod(_clazz, selector, (IMP)dynamicGetter, "@@:");
}

- (void)forwardGetter:(SEL)selector {
    class_addMethod(_counterpart, selector, (IMP)forwardingGetter, "@@:");
}

@end

void static class_swizzleClassMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation) {
    Class metaClazz = object_getClass(clazz);
    Method originalMethod = class_getClassMethod(clazz, originalSelector);
    const char *types = method_getTypeEncoding(originalMethod);

    class_addMethod(metaClazz, newSelector, implementation, types);
    Method newMethod = class_getClassMethod(clazz, newSelector);

    if (class_addMethod(metaClazz, originalSelector, implementation, types)) {
        class_replaceMethod(metaClazz, newSelector, method_getImplementation(originalMethod), types);
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }

    method_exchangeImplementations(originalMethod, newMethod);
}

void static class_swizzleInstanceMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation) {
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    const char *types = method_getTypeEncoding(originalMethod);

    class_addMethod(clazz, newSelector, implementation, types);
    Method newMethod = class_getInstanceMethod(clazz, newSelector);

    if (class_addMethod(clazz, originalSelector, implementation, types)) {
        class_replaceMethod(clazz, newSelector, method_getImplementation(originalMethod), types);
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

void static dynamicDealloc(id self, SEL _cmd) {
    //release ivars
    uint ivarsCount;
    Class clazz = object_getClass(self);
    Ivar *ivars = class_copyIvarList(clazz, &ivarsCount);
    for (uint index = 0; index < ivarsCount; index++) {
        id object = object_getIvar(self, ivars[index]);
        objc_msgSend(object, @selector(release));
    }
    free(ivars);

    //call [super dealloc]
    struct objc_super super = {
            .receiver = self,
            .super_class = class_getSuperclass(clazz)
    };
    objc_msgSendSuper(&super, _cmd);
}

id static forwardingGetter(id self, SEL _cmd) {
    return objc_msgSend(LMCache::getInstance().dynamicObjects[self], _cmd);
}

id static dynamicGetter(id self, SEL _cmd) {
    id result;
    const char *name = sel_getName(_cmd);
    object_getInstanceVariable(self, name, (void **)&result);
    if (!result) {
        objc_property_t property = class_getProperty(object_getClass(self), name);
        const char *attributes = property_getAttributes(property);
        size_t len = strlen(attributes) - 4;
        char buffer[len + 1];
        memcpy(buffer, attributes + 3, len);
        buffer[len] = '\0';
        Class clazz = objc_getClass(buffer);
        LMInitializer initializer = LMCache::getInstance().initializer(clazz);
        result = initializer ? objc_msgSend(initializer(), @selector(retain)) : objc_msgSend(clazz, @selector(new));
        object_setInstanceVariable(self, name, result);
    }
    return result;
}

void static swizzledDealloc(id self, SEL __unused _cmd) {
    [LMCache::getInstance().dynamicObjects[self] release];
    LMCache::getInstance().dynamicObjects.erase(self);
    [self dealloc_];
}

id static swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone) {
    id object = objc_msgSend(self, @selector(allocWithZone_:), zone);
    LMCache::getInstance().dynamicObjects[object] = [LMCache::getInstance().dynamicClasses[self] new];
    return object;
}

