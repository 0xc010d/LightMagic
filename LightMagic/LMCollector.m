#import <objc/runtime.h>
#import "LMCollector.h"
#import "LMClass.h"
#import "LMProperty.h"

@implementation LMCollector

+ (NSSet *)classesForProtocol:(Protocol *)protocol {
    NSMutableSet *result = [NSMutableSet set];

    uint classesCount;
    char const *imageName = class_getImageName(object_getClass(self));
    const char **classNames = objc_copyClassNamesForImage(imageName, &classesCount);

    for (uint index = 0; index < classesCount; index++) {
        Class nextClass = objc_getClass(classNames[index]);
        if ([nextClass conformsToProtocol:protocol]) {
            NSSet *properties = [self injectablePropertiesForClass:nextClass protocol:protocol];
            LMClass *clazz = [[LMClass alloc] initWithClass:nextClass properties:properties];
            [result addObject:clazz];
        }
    }

    free(classNames);

    return [NSSet setWithSet:result];
}

+ (NSSet *)injectablePropertiesForClass:(Class)clazz protocol:(Protocol *)protocol {
    NSMutableSet *properties = [NSMutableSet set];
    Class nextClass = clazz;
    
    do {
        if (class_conformsToProtocol(nextClass, protocol)) {
            uint propertiesCount;
            objc_property_t *propertyList = class_copyPropertyList(nextClass, &propertiesCount);

            for (uint i = 0; i < propertiesCount; i++) {
                LMProperty *property = [[LMProperty alloc] initWithProperty:propertyList[i]];
                [property parse];
                if (property.injectable) {
                    [properties addObject:property];
                }
            }
            free(propertyList);
        }
        nextClass = class_getSuperclass(nextClass);
    } while ([nextClass conformsToProtocol:protocol]);
    
    return [NSSet setWithSet:properties];
}

@end
