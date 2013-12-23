#import "Test.h"
#import "LightMagic.h"
#import <objc/runtime.h>
#import <BloodMagic/BMLazy.h>

@interface Test () <LightMagic>
@end

@implementation Test

@dynamic lazyObject;

- (NSObject *)ivarObject {
    if (!_ivarObject) {
        self.ivarObject = [[NSObject alloc] init];
    }
    return _ivarObject;
}

- (NSObject *)associatedObject {
    static char const associatedObjectKey;
    id associatedObject = objc_getAssociatedObject(self, &associatedObjectKey);
    if (!associatedObject) {
        associatedObject = [[NSObject alloc] init];
        objc_setAssociatedObject(self, &associatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return associatedObject;
}

@end
