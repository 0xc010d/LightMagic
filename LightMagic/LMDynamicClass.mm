#import <objc/runtime.h>
#import <objc/message.h>
#import "LMDynamicClass.h"
#import "LMCache.h"

static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

static id dynamicGetter(id self, SEL _cmd);
static void dynamicDealloc(id self, SEL  __unused _cmd);

@implementation LMDynamicClass {
    Class _clazz;
}

+ (void)initialize {
    kRootClass = [NSObject class];
    kSuffixLength = strlen(kSuffix);
}

- (instancetype)initWithBaseName:(const char *)baseName {
    self = [super init];

    size_t nameLength = strlen(baseName) + kSuffixLength;
    char name[nameLength + 1];
    sprintf(name, "%s%s", baseName, kSuffix);

    _clazz = objc_allocateClassPair(kRootClass, (const char *)name, 0);
    class_addMethod(_clazz, @selector(dealloc), (IMP)dynamicDealloc, "v@:");

    return self;
}

- (Class)clazz {
    return _clazz;
}

- (void)register {
    objc_registerClassPair(_clazz);
}

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector {
    const char *name = sel_getName(selector);
    NSUInteger size, align;
    const char *encoding = @encode(id);
    NSGetSizeAndAlignment(encoding, &size, &align);
    class_addIvar(_clazz, name, size, (uint8_t)align, encoding);

    const char *className = class_getName(clazz);
    objc_property_attribute_t attributes[] = {"T", className};
    class_addProperty(_clazz, name, attributes, 1);

    class_addMethod(_clazz, selector, (IMP)dynamicGetter, "@@:");
}

@end

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

id static dynamicGetter(id self, SEL _cmd) {
    id result;
    const char *name = sel_getName(_cmd);
    object_getInstanceVariable(self, name, (void **)&result);
    if (!result) {
        objc_property_t property = class_getProperty(object_getClass(self), name);
        const char *className = property_getAttributes(property) + 1;
        Class clazz = objc_getClass(className);
        LMInitializer initializer = LMCache::getInstance().initializer(clazz);
        if (initializer) {
            id sender = LMCache::getInstance().reversedObjects[self];
            result = objc_msgSend(initializer(sender), @selector(retain));
        }
        else {
            result = objc_msgSend(clazz, @selector(new));
        }
        object_setInstanceVariable(self, name, result);
    }
    return result;
}
