#import <objc/runtime.h>
#import <objc/message.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"
#include "LMCache.h"

void static lm_objc_swizzleClassMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation);
void static lm_objc_swizzleInstanceMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation);

id static swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone);
id static forwardingGetter(id self, SEL _cmd);
void static swizzledDealloc(id self, SEL __unused _cmd);

@interface NSObject (LMSelector)

+ (instancetype)allocWithZone_:(NSZone *)zone;
- (void)dealloc_;

@end

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

    lm_objc_swizzleClassMethod(_class, @selector(allocWithZone:), @selector(allocWithZone_:), (IMP)swizzledAllocWithZone);
    lm_objc_swizzleInstanceMethod(_class, @selector(dealloc), @selector(dealloc_), (IMP)swizzledDealloc);

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

id static swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone) {
    id object = objc_msgSend(self, @selector(allocWithZone_:), zone);
    Class injectedClass = LMCache::getInstance().injectedClasses[self];
    id injectedObject = objc_msgSend(injectedClass, @selector(new));
    LMCache::getInstance().injectedObjects.set(object, injectedObject);
    return object;
}

id static forwardingGetter(id self, SEL _cmd) {
    return objc_msgSend(LMCache::getInstance().injectedObjects[self], _cmd);
}

void static swizzledDealloc(id self, SEL __unused _cmd) {
    id injectedObject = LMCache::getInstance().injectedObjects[self];
    LMCache::getInstance().injectedObjects.erase(self);
    [injectedObject release];
    objc_msgSend(self, @selector(dealloc_));
}

#pragma mark - Helpers

void static lm_objc_swizzleClassMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation) {
    Class metaClazz = object_getClass(clazz);
    Method originalMethod = class_getClassMethod(clazz, selector);
    const char *types = method_getTypeEncoding(originalMethod);
    class_addMethod(metaClazz, newSelector, implementation, types);
    Method newMethod = class_getClassMethod(clazz, newSelector);
    if (class_addMethod(metaClazz, selector, implementation, types)) {
        class_replaceMethod(metaClazz, newSelector, method_getImplementation(originalMethod), types);
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

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
