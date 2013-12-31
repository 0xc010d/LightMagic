#import <objc/runtime.h>
#import <objc/message.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"
#import "LMCache.h"

void static class_swizzleMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation, BOOL classMethod);

id static swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone);
id static forwardingGetter(id self, SEL _cmd);
void static swizzledDealloc(id self, SEL __unused _cmd);

@interface NSObject (LMSelector)

+ (instancetype)allocWithZone_:(NSZone *)zone;
- (void)dealloc_;

@end

@implementation LMClass {
    Class _clazz;
    NSSet *_injectableProperties;
}

- (instancetype)initWithClass:(Class)clazz properties:(NSSet *)properties {
    self = [super init];
    _clazz = clazz;
    _injectableProperties = [properties retain];
    return self;
}

- (BOOL)shouldInjectGetters {
    return [_injectableProperties count] > 0;
}

- (void)injectGetters {
    LMDynamicClass *injectedClass = [[LMDynamicClass alloc] initWithBaseName:class_getName(_clazz)];
    for (LMProperty *property in _injectableProperties) {
        SEL getter = property.getter;
        [injectedClass addPropertyWithClass:property.clazz getter:getter];
        [self forwardGetter:getter];
    }

    [injectedClass register];

    class_swizzleMethodWithImplementation(_clazz, @selector(allocWithZone:), @selector(allocWithZone_:), (IMP)swizzledAllocWithZone, YES);
    class_swizzleMethodWithImplementation(_clazz, @selector(dealloc), @selector(dealloc_), (IMP)swizzledDealloc, NO);

    LMCache::getInstance().dynamicClasses[_clazz] = [injectedClass clazz];
    [injectedClass release];
}

- (void)forwardGetter:(SEL)selector {
    class_addMethod(_clazz, selector, (IMP)forwardingGetter, "@@:");
}

- (void)dealloc {
    [_injectableProperties release];
    [super dealloc];
}

@end

id static swizzledAllocWithZone(Class self, SEL __unused _cmd, NSZone *zone) {
    id object = objc_msgSend(self, @selector(allocWithZone_:), zone);
    Class dynamicClass = LMCache::getInstance().dynamicClasses[self];
    id dynamicObject = objc_msgSend(dynamicClass, @selector(new));
    LMCache::getInstance().dynamicObjects[object] = dynamicObject;
    LMCache::getInstance().reversedObjects[dynamicObject] = object;
    return object;
}

id static forwardingGetter(id self, SEL _cmd) {
    return objc_msgSend(LMCache::getInstance().dynamicObjects[self], _cmd);
}

void static swizzledDealloc(id self, SEL __unused _cmd) {
    id dynamicObject = LMCache::getInstance().dynamicObjects[self];
    LMCache::getInstance().dynamicObjects.erase(self);
    LMCache::getInstance().reversedObjects.erase(dynamicObject);
    [dynamicObject release];
    objc_msgSend(self, @selector(dealloc_));
}

#pragma mark - Helpers

void static class_swizzleMethodWithImplementation(Class clazz, SEL originalSelector, SEL newSelector, IMP implementation, BOOL classMethod) {
    Class metaClazz;
    const char *types;
    Method originalMethod, newMethod;
    if (classMethod) {
        metaClazz = object_getClass(clazz);
        originalMethod = class_getClassMethod(clazz, originalSelector);
        types = method_getTypeEncoding(originalMethod);
        class_addMethod(metaClazz, newSelector, implementation, types);
        newMethod = class_getClassMethod(clazz, newSelector);
    }
    else {
        metaClazz = clazz;
        originalMethod = class_getInstanceMethod(clazz, originalSelector);
        types = method_getTypeEncoding(originalMethod);
        class_addMethod(metaClazz, newSelector, implementation, types);
        newMethod = class_getInstanceMethod(clazz, newSelector);
    }

    if (class_addMethod(metaClazz, originalSelector, implementation, types)) {
        class_replaceMethod(metaClazz, newSelector, method_getImplementation(originalMethod), types);
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
