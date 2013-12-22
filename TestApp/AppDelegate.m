#import "AppDelegate.h"
#include <mach/mach_time.h>
#import "Test.h"
#import "LightMagic.h"

typedef struct TestResults {
    int64_t lazyTime;
    int64_t associatedTime;
    int64_t ivarTime;
    float lazyToAssociatedRatio;
    float lazyToIvarRatio;
} TestResults;

static inline TestResults runTest(NSInteger loop, NSInteger callLoop);

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

    NSInteger loop = 1000000;

    for (NSInteger callLoop = 10; callLoop <= 10; callLoop++) {
        TestResults results = runTest(loop, callLoop);
        NSLog(@"%lld", results.lazyTime);
        NSLog(@"%lld", results.associatedTime);
        NSLog(@"%lld", results.ivarTime);
        NSLog(@"%f %f", results.lazyToAssociatedRatio, results.lazyToIvarRatio);
    }

    NSLog(@"Done");

    Test *test = [[Test alloc] init];
    NSLog(@"%@", [[test lazyObject] class]);
    NSLog(@"%@", [[test lazyObject] class]);

    LM_REGISTER_INITIALIZER(NSObject, ^id {
        return [NSSet setWithObject:[NSObject new]];
    });

    @autoreleasepool {
        test = [[Test alloc] init];
        NSLog(@"%@", [test lazyObject]);
        NSLog(@"%@", [test lazyObject]);
    }

    dispatch_after(10, dispatch_get_main_queue(), ^{
        NSLog(@"%@", [test lazyObject]);
    });

    LM_UNREGISTER_INITIALIZER(NSObject);
    test = [[Test alloc] init];
    NSLog(@"%@", [test lazyObject]);

    NSLog(@"Done");

    return YES;
}

@end

LM_CONTEXT(initializers,
LM_REGISTER_INITIALIZER(NSObject, ^id {
    return [NSArray array];
});
)

static TestResults runTest(NSInteger loop, NSInteger callLoop) {
    TestResults results;

    uint64_t startTime;

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [Test new];
            for (int j = 0; j < callLoop; j++) {
                [test lazyObject];
            }
        }
        results.lazyTime = mach_absolute_time() - startTime;
    }

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [Test new];
            for (int j = 0; j < callLoop; j++) {
                [test associatedObject];
            }
        }
        results.associatedTime = mach_absolute_time() - startTime;
    }

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [Test new];
            for (int j = 0; j < callLoop; j++) {
                [test ivarObject];
            }
        }
        results.ivarTime = mach_absolute_time() - startTime;
    }


    results.lazyToAssociatedRatio = (float)results.lazyTime / results.associatedTime;
    results.lazyToIvarRatio = (float)results.lazyTime / results.ivarTime;

    return results;
}