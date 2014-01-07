#import "LMContext.h"
#import "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)propertyClass {
    LMCache::getInstance().setInitializer(initializer, propertyClass);
}

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMCache::getInstance().setInitializer(initializer, propertyClass, containerClass);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass {
    LMCache::getInstance().removeInitializer(propertyClass);
}

+ (void)unregisterInitializerForClass:(Class)propertyClass containerClass:(Class)containerClass {
    LMCache::getInstance().removeInitializer(propertyClass, containerClass);
}

@end
