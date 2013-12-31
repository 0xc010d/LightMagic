#import "LMCache.h"

@interface LMCacheTests : XCTestCase
@end

@implementation LMCacheTests {
    LMCache *_cache;
}

- (void)setUp {
    _cache = new LMCache();
}

- (void)tearDown {
    delete _cache;
}

- (void)testDataClearing {
    _cache->setInitializer([NSObject class], ^id(id sender) {
        return nil;
    });
    _cache->dynamicClasses[[NSObject class]] = [NSArray class];
    _cache->dynamicObjects[[[NSObject alloc] init]] = [[NSObject alloc] init];
    _cache->reversedObjects[[[NSObject alloc] init]] = [[NSObject alloc] init];

    _cache->clear();

    XCTAssert(_cache->dynamicClasses.size() == 0, @"Dynamic classes should be removed from cache");
    XCTAssert(_cache->dynamicObjects.size() == 0, @"Dynamic objects should be removed from cache");
    XCTAssert(_cache->reversedObjects.size() == 0, @"Reversed objects should be removed from cache");
    XCTAssertNil(_cache->initializer([NSObject class]), @"Initializer should not be retrievable");
}

@end