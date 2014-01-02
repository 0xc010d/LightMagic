#import "LMContext.h"
#import "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz {
    LMCache::getInstance().setInitializer(initializer, clazz);
}

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz containerClass:(Class)containerClass {
    LMCache::getInstance().setInitializer(initializer, clazz, containerClass);
}


+ (void)unregisterInitializerForClass:(Class)clazz {
    LMCache::getInstance().removeInitializer(clazz);
}

+ (void)unregisterInitializerForClass:(Class)clazz containerClass:(Class)containerClass {
    LMCache::getInstance().removeInitializer(clazz, containerClass);
}


@end
