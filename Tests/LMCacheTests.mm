#import <Kiwi.h>
#import "LMCache.h"

SPEC_BEGIN(LMCacheTests)
        describe(@"Cache consistency", ^{
            context(@"Initializers", ^{
                __block LMCache *cache;
                beforeEach(^{
                    cache = new LMCache();
                    cache->setInitializer(^id(id sender) {
                                            return nil;
                                        }, [NSObject class], Nil);
                });
                afterEach(^{
                    delete cache;
                });
                it(@"Initializer should not be retrievable after removing", ^{
                    cache->removeInitializer([NSObject class], Nil);
                    [[cache->initializer([NSObject class], Nil) should] beNil];
                });
                it(@"Initializer should be runnable", ^{
                    [[cache->initializer([NSObject class], Nil)(nil) should] beNil];
                });
                it(@"Initializer should be rewritable", ^{
                    [[cache->initializer([NSObject class], Nil)(nil) should] beNil];
                    cache->setInitializer(^id(id sender) {
                        return [NSArray array];
                    }, [NSObject class], Nil);
                    [[cache->initializer([NSObject class], Nil)(nil) shouldNot] beNil];
                });
                it(@"Initializer parameter should be accessable", ^{
                    cache->setInitializer(^id(id sender) {
                        return [NSArray arrayWithObject:sender];
                    }, [NSObject class], Nil);
                    NSObject *object = [NSObject new];
                    [[theValue([cache->initializer([NSObject class], Nil)(object) count]) should] equal:theValue(1)];
                    [[cache->initializer([NSObject class], Nil)(object)[0] should] equal:object];
                });
            });
        });
SPEC_END
