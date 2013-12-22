#import "LMContext.h"
#import "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz {
    LMCache::getInstance().setInitializer(clazz, initializer);
}

+ (void)removeInitializerForClass:(Class)clazz {
    LMCache::getInstance().removeInitializer(clazz);
}

@end
