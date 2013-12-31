#import <Kiwi.h>
#import "LMCache.h"

SPEC_BEGIN(LMCacheTests)
        describe(@"Cache consistency", ^{
            context(@"Data clearing", ^{
                __block LMCache *cache;
                beforeEach(^{
                    cache = new LMCache();
                });
                afterEach(^{
                    delete cache;
                });
                it(@"Initializer should not be retrievable", ^{
                    cache->setInitializer([NSObject class], ^id(id sender) { return nil; });
                    cache->clear();
                    [[cache->initializer([NSObject class]) should] beNil];
                });
                it(@"Dynamic classes should be removed from cache", ^{
                    cache->dynamicClasses[[NSObject class]] = [NSArray class];
                    cache->clear();
                    [[theValue(cache->dynamicClasses.size()) should] equal:theValue(0)];
                });
                it(@"Dynamic objects should be removed from cache", ^{
                    cache->dynamicObjects[[[NSObject alloc] init]] = [[NSObject alloc] init];
                    cache->clear();
                    [[theValue(cache->dynamicObjects.size()) should] equal:theValue(0)];
                });
                it(@"Reversed objects should be removed from cache", ^{
                    cache->reversedObjects[[[NSObject alloc] init]] = [[NSObject alloc] init];
                    cache->clear();
                    [[theValue(cache->reversedObjects.size()) should] equal:theValue(0)];
                });
            });
            context(@"Initializers", ^{
                __block LMCache *cache;
                beforeEach(^{
                    cache = new LMCache();
                    cache->setInitializer([NSObject class], ^id(id sender) { return nil; });
                });
                afterEach(^{
                    delete cache;
                });
                it(@"Initializer should not be retrievable after removing", ^{
                    cache->removeInitializer([NSObject class]);
                    [[cache->initializer([NSObject class]) should] beNil];
                });
                it(@"Initializer should be runnable", ^{
                    [[cache->initializer([NSObject class])(nil) should] beNil];
                });
                it(@"Initializer should be rewritable", ^{
                    [[cache->initializer([NSObject class])(nil) should] beNil];
                    cache->setInitializer([NSObject class], ^id(id sender) {
                        return [NSArray array];
                    });
                    [[cache->initializer([NSObject class])(nil) shouldNot] beNil];
                });
                it(@"Initializer parameter should be accessable", ^{
                    cache->setInitializer([NSObject class], ^id(id sender) {
                        return [NSArray arrayWithObject:sender];
                    });
                    NSObject *object = [NSObject new];
                    [[theValue([cache->initializer([NSObject class])(object) count]) should] equal:theValue(1)];
                    [[cache->initializer([NSObject class])(object)[0] should] equal:object];
                });
            });
        });
SPEC_END
