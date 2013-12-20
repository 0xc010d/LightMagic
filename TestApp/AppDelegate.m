#import "AppDelegate.h"
#include <mach/mach_time.h>
#import "Test.h"
#import "LMContext.h"

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

    NSInteger loop = 100000;

    for (NSInteger callLoop = 1; callLoop <= 1; callLoop++) {
        TestResults results = runTest(loop, callLoop);
        NSLog(@"%lld", results.lazyTime);
        NSLog(@"%lld", results.associatedTime);
        NSLog(@"%lld", results.ivarTime);
        NSLog(@"%f %f", results.lazyToAssociatedRatio, results.lazyToIvarRatio);
    }

    NSLog(@"Done");
    return YES;
}

@end

__attribute__((constructor(1000))) void __unused setInitializers(void) {
    [[LMContext defaultContext] setInitializer:^id {
        return [NSArray array];
    } forClass:[NSObject class]];
}

static TestResults runTest(NSInteger loop, NSInteger callLoop) {
    TestResults results;

    uint64_t startTime;

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [[Test alloc] init];
            for (int j = 0; j < callLoop; j++) {
                [test lazyObject];
            }
        }
        results.lazyTime = mach_absolute_time() - startTime;
    }

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [[Test alloc] init];
            for (int j = 0; j < callLoop; j++) {
                [test associatedObject];
            }
        }
        results.associatedTime = mach_absolute_time() - startTime;
    }

    @autoreleasepool {
        startTime = mach_absolute_time();
        for (NSInteger i = 0; i < loop; i++) {
            Test *test = [[Test alloc] init];
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