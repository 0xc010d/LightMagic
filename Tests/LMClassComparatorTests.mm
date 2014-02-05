#import <Kiwi.h>
#include "LMCache.h"

SPEC_BEGIN(LMClassComparatorTests)

        context(@"Class comparator", ^{
            __block LMClassComparator *comparator;
            beforeEach(^{
                comparator = new LMClassComparator;
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