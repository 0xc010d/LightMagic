#import <objc/runtime.h>
#import "LMClass.h"
#import "LMProperty.h"

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

static id _getter(id self, SEL _cmd) {
    char const *key = sel_getName(_cmd);
    id object = objc_getAssociatedObject(self, key);
    if (!object) {
        Class clazz = object_getClass(self);
        //run initializer
        object = ((id (^)(void))objc_getAssociatedObject(clazz, key))();
        objc_setAssociatedObject(self, key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return object;
}

- (void)injectGetters {
    NSSet *dynamicProperties = self.injectableProperties;
    for (LMProperty *property in dynamicProperties) {
        SEL getter = property.getter;
        BOOL inject = !class_respondsToSelector(_clazz, getter);
        if (inject) {
            id (^initializer)(void) = property.initializer;
            char const *key = sel_getName(getter);
            objc_setAssociatedObject(_clazz, key, initializer, OBJC_ASSOCIATION_COPY);
            class_addMethod(_clazz, getter, (IMP)_getter, "@@:");
        }
    }
}

@end
