#import <Kiwi.h>
#import "LMCache.h"

SPEC_BEGIN(LMCacheTests)
        context(@"Default initializers", ^{
            __block LMCache *cache;
            beforeEach(^{
                cache = new LMCache();
                cache->setInitializer(^id(id sender) {
                    return nil;
                }, [NSObject class]);
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
                cache->setInitializer(^id(id sender) {
                    return [NSArray array];
                }, [NSObject class]);
                [[cache->initializer([NSObject class])(nil) shouldNot] beNil];
            });
            it(@"Initializer parameter should be accessable", ^{
                cache->setInitializer(^id(id sender) {
                    return [NSArray arrayWithObject:sender];
                }, [NSObject class]);
                NSObject *object = [NSObject new];
                [[theValue([cache->initializer([NSObject class])(object) count]) should] equal:theValue(1)];
                [[cache->initializer([NSObject class])(object)[0] should] equal:object];
            });
        });
        context(@"Container initializers", ^{
            LMInitializer nilInitializer = ^id(id sender) { return nil; };
            LMInitializer arrayInitializer = ^id(id sender) { return [NSArray array]; };
            LMInitializer setInitializer = ^id(id sender) { return [NSMutableSet set]; };
            LMInitializer countedSetInitializer = ^id(id sender) { return [NSCountedSet set]; };
            LMInitializer mutableDictionaryInitializer = ^id(id sender) { return [NSMutableDictionary dictionary]; };
            __block LMCache *cache;
            beforeEach(^{
                cache = new LMCache();
            });
            afterEach(^{
                delete cache;
            });
            it(@"Subclasses should take superclasses initializers", ^{
                cache->setInitializer(nilInitializer, [NSObject class], [UIResponder class]);
                [[cache->initializer([NSObject class], [UIButton class]) shouldNot] beNil];
            });
            it(@"Nil should be returned if container initializer hasn't been found", ^{
                cache->setInitializer(nilInitializer, [NSObject class], [UIButton class]);
                [[cache->initializer([NSObject class], [UIResponder class]) should] beNil];
            });
            it(@"Default initializer should be used if other hasn't been found", ^{
                cache->setInitializer(nilInitializer, [NSObject class]);
                [[cache->initializer([NSObject class], [UIButton class]) shouldNot] beNil];
            });
            it(@"Container initializers should be removable", ^{
                cache->setInitializer(nilInitializer, [NSObject class], [UIResponder class]);
                [[cache->initializer([NSObject class], [UIButton class]) shouldNot] beNil];
                cache->removeInitializer([NSObject class], [UIResponder class]);
                [[cache->initializer([NSObject class], [UIButton class]) should] beNil];
            });
            it(@"Exact container class match should be handled", ^{
                cache->setInitializer(nilInitializer, [NSObject class], [UIResponder class]);
                [[cache->initializer([NSObject class], [UIResponder class]) shouldNot] beNil];
            });
            it(@"Exact container class match should be handled if more then one class is defined", ^{
                cache->setInitializer(nilInitializer, [NSObject class], [NSObject class]);
                cache->setInitializer(arrayInitializer, [NSObject class], [UIResponder class]);
                cache->setInitializer(nilInitializer, [NSObject class], [UIButton class]);
                [[cache->initializer([NSObject class], [UIResponder class]) should] equal:arrayInitializer];
            });
            it(@"Subclasses support should be handled properly", ^{
                cache->setInitializer(arrayInitializer, [NSObject class], [UIBarItem class]);
                cache->setInitializer(nilInitializer, [NSObject class], [NSObject class]);
                [[cache->initializer([NSObject class], [UIBarButtonItem class]) should] equal:arrayInitializer];
                [[cache->initializer([NSObject class], [UIView class]) should] equal:nilInitializer];
            });
            it(@"Complex hierarchy should be handled properly", ^{
                cache->setInitializer(arrayInitializer, [NSObject class], [NSArray class]);
                cache->setInitializer(setInitializer, [NSObject class], [NSSet class]);
                cache->setInitializer(mutableDictionaryInitializer, [NSObject class], [NSMutableDictionary class]);
                cache->setInitializer(countedSetInitializer, [NSObject class], [NSCountedSet class]);
                cache->setInitializer(nilInitializer, [NSObject class], [NSProxy class]);
                [[cache->initializer([NSObject class]) should] beNil];
                [[cache->initializer([NSObject class], [NSObject class]) should] beNil];
                [[cache->initializer([NSObject class], [NSProxy class]) should] equal:nilInitializer];
                [[cache->initializer([NSObject class], [NSCountedSet class]) should] equal:countedSetInitializer];
                [[cache->initializer([NSObject class], [NSMutableDictionary class]) should] equal:mutableDictionaryInitializer];
                [[cache->initializer([NSObject class], [NSMutableSet class]) should] equal:setInitializer];
                [[cache->initializer([NSObject class], [NSArray class]) should] equal:arrayInitializer];
            });
        });
        context(@"Container initializers comparator", ^{
            __block ClassCompare *comparator;
            beforeEach(^{
                comparator = new ClassCompare;
            });
            afterEach(^{
                delete comparator;
            });
            it(@"Should properly handle equal classes", ^{
                [[theValue(comparator->operator()([NSObject class], [NSObject class])) should] equal:theValue(false)];
            });
            it(@"Should properly handle subclasses", ^{
                [[theValue(comparator->operator()([NSArray class], [NSObject class])) should] equal:theValue(true)];
                [[theValue(comparator->operator()([NSObject class], [NSArray class])) should] equal:theValue(false)];
            });
            it(@"Should properly handle unconnected classes", ^{
                bool result = [NSArray class] < [NSDictionary class];
                [[theValue(comparator->operator()([NSArray class], [NSDictionary class])) should] equal:theValue(result)];
                [[theValue(comparator->operator()([NSDictionary class], [NSArray class])) should] equal:theValue(!result)];
            });
        });
SPEC_END
