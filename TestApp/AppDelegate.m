#import "AppDelegate.h"
#include <mach/mach_time.h>
#import "Test.h"
#import "LightMagic.h"
#import "ViewController.h"

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
    ViewController *rootViewController = [[ViewController alloc] init];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];

    NSInteger loop = 100000;
    NSInteger callLoop = 100;

    TestResults results = runTest(loop, callLoop);

    rootViewController.lazyLabel.text = [NSString stringWithFormat:@"%lld", results.lazyTime];
    rootViewController.associatedLabel.text = [NSString stringWithFormat:@"%lld", results.associatedTime];
    rootViewController.ivarLabel.text = [NSString stringWithFormat:@"%lld", results.ivarTime];
    rootViewController.ratioLabel.text = [NSString stringWithFormat:@"%f %f", results.lazyToAssociatedRatio, results.lazyToIvarRatio];
    
    NSLog(@"%lld", results.lazyTime);
    NSLog(@"%lld", results.associatedTime);
    NSLog(@"%lld", results.ivarTime);
    NSLog(@"%f %f", results.lazyToAssociatedRatio, results.lazyToIvarRatio);

    NSLog(@"Done");

    Test *test = [[Test alloc] init];
    NSLog(@"%@", [[test lazyObject] class]);

    LM_REGISTER_INITIALIZER(NSObject, ^id (id sender) {
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
    NSLog(@"%@", [test lazyObject]);

    NSLog(@"Done");

    return YES;
}

@end

LM_CONTEXT(initializers,
LM_REGISTER_INITIALIZER(NSObject, ^id (id sender) {
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