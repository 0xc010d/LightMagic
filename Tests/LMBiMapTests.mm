#import <Kiwi.h>
#include "LMBiMap.h"

SPEC_BEGIN(LMBiMapTests)
        context(@"Natural ordered map", ^{
            __block LMBiMap<int, char> *map;
            beforeEach(^{
                map = new LMBiMap<int, char>;
            });
            afterEach(^{
                delete map;
            });
            it(@"Should set values", ^{
                map->set(1, '2');
                map->set(3, '4');
                [[theValue((*map)[1]) should] equal:theValue('2')];
                [[theValue(map->reversed()['4']) should] equal:theValue(3)];
            });
            it(@"Should update values", ^{
                map->set(1, '2');
                map->set(1, '3');
                map->set(3, '4');
                [[theValue((*map)[1]) should] equal:theValue('3')];
                [[theValue(map->reversed()['3']) should] equal:theValue(1)];
                [[theValue(map->reversed()['2']) should] equal:theValue(0)];
            });
            it(@"Should erase values", ^{
                map->set(1, '2');
                map->set(3, '4');
                map->erase(1);
                [[theValue((*map)[1]) should] equal:theValue(0)];
                [[theValue((*map)[3]) should] equal:theValue('4')];
            });
        });
        context(@"Reverse ordered map", ^{
            __block LMBiMap<int, char> *map;
            beforeEach(^{
                map = new LMBiMap<int, char>;
            });
            afterEach(^{
                delete map;
            });
            it(@"Should set values", ^{
                map->reversed().set('1', 2);
                [[theValue((*map)[2]) should] equal:theValue('1')];
            });
            it(@"Should update values", ^{
                map->set(1, '2');
                map->reversed().set('2', 3);
                [[theValue((*map)[1]) should] equal:theValue(0)];
                [[theValue((*map)[3]) should] equal:theValue('2')];
            });
            it(@"Should erase values", ^{
                map->set(1, '2');
                map->reversed().erase('2');
                [[theValue((*map)[1]) should] equal:theValue(0)];
            });
        });
        context(@"Equal Key and Value types", ^{
            __block LMBiMap<int, int> *map;
            beforeEach(^{
                map = new LMBiMap<int, int>;
            });
            afterEach(^{
                delete map;
            });
            it(@"Should set natural values", ^{
                map->set(1, 2);
                map->set(3, 4);
                [[theValue((*map)[1]) should] equal:theValue(2)];
                [[theValue(map->reversed()[4]) should] equal:theValue(3)];
            });
            it(@"Should update natural values", ^{
                map->set(1, 2);
                map->set(1, 3);
                [[theValue((*map)[1]) should] equal:theValue(3)];
                [[theValue(map->reversed()[3]) should] equal:theValue(1)];
                [[theValue(map->reversed()[2]) should] equal:theValue(0)];
            });
            it(@"Should erase natural values", ^{
                map->set(1, 2);
                map->set(3, 4);
                map->erase(1);
                [[theValue((*map)[1]) should] equal:theValue(0)];
            });
            it(@"Should set reversed values", ^{
                map->reversed().set(1, 2);
                [[theValue((*map)[2]) should] equal:theValue(1)];
            });
            it(@"Should update reversed values", ^{
                map->set(1, 2);
                map->reversed().set(2, 3);
                [[theValue((*map)[1]) should] equal:theValue(0)];
                [[theValue((*map)[3]) should] equal:theValue(2)];
            });
            it(@"Should erase reversed values", ^{
                map->set(1, 2);
                map->reversed().erase(2);
                [[theValue((*map)[1]) should] equal:theValue(0)];
            });
        });
SPEC_END