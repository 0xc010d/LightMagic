#import <objc/runtime.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"

@interface LMClass ()

@property (nonatomic, strong) NSSet *injectableProperties;

@end

@implementation LMClass {
    Class _clazz;
}

- (instancetype)initWithClass:(Class)clazz {
    self = [super init];
    _clazz = clazz;
    return self;
}

- (NSSet *)injectableProperties {
    if (!_injectableProperties) {
        self.injectableProperties = ({
            NSMutableSet *injectableProperties = [NSMutableSet set];
            uint propertiesCount;
            objc_property_t *properties = class_copyPropertyList(_clazz, &propertiesCount);

            for (uint i = 0; i < propertiesCount; i++) {
                LMProperty *property = [[LMProperty alloc] initWithProperty:properties[i]];
                [property parse];
                if (property.injectable) {
                    [injectableProperties addObject:property];
                }
            }
            free(properties);

            [NSSet setWithSet:injectableProperties];
        });
    }
    return _injectableProperties;
}

- (void)injectGetters {
    LMDynamicClass *injectedClass = [[LMDynamicClass alloc] initForClass:_clazz
                                                              properties:self.injectableProperties];
    [injectedClass createAndInject];
}

@end
