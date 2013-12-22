#import <objc/runtime.h>
#import "LMClass.h"
#import "LMProperty.h"
#import "LMDynamicClass.h"

@interface LMClass ()

@property (nonatomic, strong) NSSet *injectableProperties;

@end

@implementation LMClass {
    Class _clazz;
    Protocol *_protocol;
}

- (instancetype)initWithClass:(Class)clazz protocol:(Protocol *)protocol {
    self = [super init];
    _clazz = clazz;
    _protocol = protocol;
    return self;
}

- (NSSet *)injectableProperties {
    if (!_injectableProperties) {
        self.injectableProperties = ({
            NSMutableSet *properties = [NSMutableSet set];
            Class clazz = _clazz;

            do {
                uint propertiesCount;
                objc_property_t *propertyList = class_copyPropertyList(clazz, &propertiesCount);

                for (uint i = 0; i < propertiesCount; i++) {
                    LMProperty *property = [[LMProperty alloc] initWithProperty:propertyList[i]];
                    [property parse];
                    if (property.injectable) {
                        [properties addObject:property];
                    }
                }
                free(propertyList);
                clazz = class_getSuperclass(clazz);
            } while (class_conformsToProtocol(clazz, _protocol));

            [NSSet setWithSet:properties];
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
