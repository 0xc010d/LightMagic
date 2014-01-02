#import "LMContext.h"
#import "LMCache.h"

@implementation LMContext

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz {
    LMCache::getInstance().setInitializer(initializer, clazz, Nil);
}

+ (void)removeInitializerForClass:(Class)clazz {
    LMCache::getInstance().removeInitializer(clazz, Nil);
}

@end
