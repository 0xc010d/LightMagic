#import <objc/runtime.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"
#import "LMCollector.h"

@implementation LMClass {
    Class _clazz;
    Protocol *_protocol;
    NSSet *_injectableProperties;
}

- (instancetype)initWithClass:(Class)clazz properties:(NSSet *)properties {
    self = [super init];
    _clazz = clazz;
    _injectableProperties = properties;
    return self;
}

- (BOOL)shouldInjectGetters {
    return [_injectableProperties count] > 0;
}

- (void)injectGetters {
    LMDynamicClass *injectedClass = [[LMDynamicClass alloc] initForClass:_clazz
                                                              properties:_injectableProperties];
    [injectedClass createAndInject];
}

@end
