#import "LMContext.h"
#include "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializerBlock)initializer forClass:(Class)propertyClass {
    LMTypeDescriptor type(propertyClass);
    LMInitializerDescriptor descriptor(type);
    LMCache::getInstance().setInitializer(initializer, descriptor);
}

+ (void)registerInitializer:(LMInitializerBlock)initializer forClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMTypeDescriptor type(propertyClass);
    LMInitializerDescriptor descriptor(type, containerClass);
    LMCache::getInstance().setInitializer(initializer, descriptor);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass {
    LMTypeDescriptor type(propertyClass);
    LMInitializerDescriptor descriptor(type);
    LMCache::getInstance().removeInitializer(descriptor);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMTypeDescriptor type(propertyClass);
    LMInitializerDescriptor descriptor(type, containerClass);
    LMCache::getInstance().removeInitializer(descriptor);
}

@end
