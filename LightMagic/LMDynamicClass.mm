#import <objc/runtime.h>
#import <objc/message.h>
#import "LMDynamicClass.h"
#import "LMProperty.h"
#import "LMCache.h"
#import "LMImplementation.h"

static const char *kRootClassName = "NSObject";
static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

static void class_swizzleClassMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation);
static void class_swizzleInstanceMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation);
static void dynamic_object_dealloc(id self, SEL  __unused _cmd);

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
    //TODO: invent something to deal with custom +alloc and +new
    class_swizzleClassMethodWithImplementation(_counterpart, @selector(allocWithZone:), LMSelectorAllocWithZone, imp(LMSelectorAllocWithZone));
}

- (void)swizzleDealloc {
    class_swizzleInstanceMethodWithImplementation(_counterpart, @selector(dealloc), LMSelectorDealloc, imp(LMSelectorDealloc));
}

- (void)addDealloc {
    class_addMethod(_clazz, @selector(dealloc), (IMP)dynamic_object_dealloc, "v@:");
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

    class_addMethod(_clazz, selector, getter(NO), "@@:");
}

- (void)forwardGetter:(SEL)selector {
    class_addMethod(_counterpart, selector, getter(YES), "@@:");
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

void static dynamic_object_dealloc(id self, SEL _cmd) {
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