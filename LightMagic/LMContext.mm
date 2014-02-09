#import "LMContext.h"
#include "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializerBlock)initializer forClass:(Class)propertyClass {
    LMPropertyDescriptor descriptor(propertyClass);
    LMCache::getInstance().setInitializer(initializer, descriptor);
}

+ (void)registerInitializer:(LMInitializerBlock)initializer forClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMPropertyDescriptor descriptor(propertyClass, containerClass);
    LMCache::getInstance().setInitializer(initializer, descriptor);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass {
    LMPropertyDescriptor descriptor(propertyClass);
    LMCache::getInstance().removeInitializer(descriptor);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMPropertyDescriptor descriptor(propertyClass, containerClass);
    LMCache::getInstance().removeInitializer(descriptor);
}

@end
