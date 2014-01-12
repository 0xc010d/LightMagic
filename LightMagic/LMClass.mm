#import <objc/runtime.h>
#import <objc/message.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"
#include "LMCache.h"

void static lm_objc_swizzleInstanceMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation);

id static forwardingGetter(id self, SEL _cmd);
void static swizzledDealloc(id self, SEL __unused _cmd);

@implementation LMClass {
    Class _class;
    NSSet *_injectableProperties;
}

- (instancetype)initWithClass:(Class)containerClass properties:(NSSet *)properties {
    self = [super init];
    _class = containerClass;
    _injectableProperties = [properties retain];
    return self;
}

- (BOOL)shouldInjectGetters {
    return [_injectableProperties count] > 0;
}

- (void)injectGetters {
    LMDynamicClass *dynamicClass = [[LMDynamicClass alloc] initWithContainerClass:_class];
    for (LMProperty *property in _injectableProperties) {
        [dynamicClass addPropertyWithClass:property.clazz protocols:property.protocols getter:property.getter];
        [self forwardGetter:property.getter];
    }

    [dynamicClass register];

    const char *baseName = class_getName(_class);
    const char *deallocSuffix = "_dealloc";
    const size_t deallocNameLength = strlen(baseName) + strlen(deallocSuffix);
    char deallocName[deallocNameLength + 1];
    sprintf(deallocName, "%s%s", baseName, deallocSuffix);
    SEL deallocSelector = sel_getUid(deallocName);
    lm_objc_swizzleInstanceMethod(_class, @selector(dealloc), deallocSelector, (IMP)swizzledDealloc);

    Class injectedClass = [dynamicClass injectedClass];
    LMCache::getInstance().injectedClasses.set(_class, injectedClass);
    [dynamicClass release];
}

- (void)forwardGetter:(SEL)selector {
    class_addMethod(_class, selector, (IMP)forwardingGetter, "@@:");
}

- (void)dealloc {
    [_injectableProperties release];
    [super dealloc];
}

@end

id static forwardingGetter(id self, SEL _cmd) {
    id object = LMCache::getInstance().injectedObjects[self];
    if (!object) {
        Class injectedClass = LMCache::getInstance().injectedClasses[[self class]];
        object = objc_msgSend(injectedClass, @selector(new));
        LMCache::getInstance().injectedObjects.set(self, object);
    }
    return objc_msgSend(object, _cmd);
}

void static swizzledDealloc(id self, SEL __unused _cmd) {
    id injectedObject = LMCache::getInstance().injectedObjects[self];
    if (injectedObject) {
        LMCache::getInstance().injectedObjects.erase(self);
        [injectedObject release];
    }

    static const char *suffix = "_dealloc";
    const char *baseName = class_getName([self class]);
    size_t nameLength = strlen(baseName) + strlen(suffix);
    char name[nameLength + 1];
    sprintf(name, "%s%s", baseName, suffix);
    SEL selector = sel_getUid(name);
    objc_msgSend(self, selector);
}

#pragma mark - Helpers

void static lm_objc_swizzleInstanceMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation) {
    Method originalMethod = class_getInstanceMethod(clazz, selector);
    const char *types = method_getTypeEncoding(originalMethod);
    class_addMethod(clazz, newSelector, implementation, types);
    Method newMethod = class_getInstanceMethod(clazz, newSelector);
    if (class_addMethod(clazz, selector, implementation, types)) {
        class_replaceMethod(clazz, newSelector, method_getImplementation(originalMethod), types);
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
