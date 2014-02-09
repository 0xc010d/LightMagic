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
        [dynamicClass addPropertyWithDescriptor:property.descriptor getter:property.getter];
        [self forwardGetter:property.getter];
    }

    [dynamicClass register];

    SEL deallocSelector = sel_getUid("dealloc_");
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

    SEL selector = sel_getUid("dealloc_");
    objc_msgSend(self, selector);
}

#pragma mark - Helpers

void static lm_objc_swizzleInstanceMethod(Class clazz, SEL selector, SEL newSelector, IMP implementation) {
    Method originalMethod = class_getInstanceMethod(clazz, selector);
    IMP originalImplementation = method_getImplementation(originalMethod);
    // check if we haven't swizzled this method before
    // this check requires classes to be sorted (see LMCollector)
    //TODO: does it really require that?
    if (originalImplementation != implementation) {
        const char *types = method_getTypeEncoding(originalMethod);
        if (class_addMethod(clazz, selector, implementation, types)) {
            class_addMethod(clazz, newSelector, originalImplementation, types);
        }
        else {
            class_addMethod(clazz, newSelector, implementation, types);
            Method newMethod = class_getInstanceMethod(clazz, newSelector);
            method_exchangeImplementations(originalMethod, newMethod);
        }
    }
}
