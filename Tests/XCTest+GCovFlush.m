//https://github.com/leroymattingly/XCode5gcovPatch

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

extern void __gcov_flush();

@interface XCTest (GCovFlush)
@end

@implementation XCTest (GCovFlush)

+ (void)load {
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(tearDown));
    swizzled = class_getInstanceMethod(self, @selector(_swizzledTearDown));
    method_exchangeImplementations(original, swizzled);
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
- (void)_swizzledTearDown {
    if (__gcov_flush) {
        __gcov_flush();
    }
    [self _swizzledTearDown];
}
#pragma clang diagnostic pop

@end