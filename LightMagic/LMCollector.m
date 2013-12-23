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
        if (class_conformsToProtocol(nextClass, protocol)) {
            NSSet *properties = [self injectablePropertiesForClass:nextClass protocol:protocol];
            LMClass *clazz = [[LMClass alloc] initWithClass:nextClass properties:properties];
            [result addObject:clazz];
        }
    }

    free(classNames);

    return [NSSet setWithSet:result];
}

+ (NSSet *)injectablePropertiesForClass:(Class)_clazz protocol:(Protocol *)protocol {
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
    } while (class_conformsToProtocol(clazz, protocol));
    
    return [NSSet setWithSet:properties];
}

@end
