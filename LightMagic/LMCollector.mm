#import <objc/runtime.h>
#include <set>
#import "LMCollector.h"
#import "LMClass.h"
#import "LMProperty.h"

@implementation LMCollector

+ (NSSet *)classesForProtocol:(Protocol *)protocol {
    NSMutableSet *result = [NSMutableSet set];

    uint classesCount;
    char const *imageName = class_getImageName(object_getClass(self));
    const char **classNames = objc_copyClassNamesForImage(imageName, &classesCount);

    struct ClassComparator {
        bool operator() (Class a, Class b) const {
            if (a == b) return false;
            else if ([a isSubclassOfClass:b]) return false;
            else if ([b isSubclassOfClass:a]) return true;
            else return a < b;
        }
    };

    // we need to sort all classes to get easy swizzling support;
    // we'll swizzle -dealloc in LMClass
    std::set<Class, ClassComparator> classes;
    for (int index = 0; index < classesCount; index++) {
        Class nextClass = objc_getClass(classNames[index]);
        classes.insert(nextClass);
    }

    for (auto iterator = classes.begin(); iterator != classes.end(); iterator ++) {
        Class nextClass = *iterator;
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
                if ([property isInjectableInClass:nextClass]) {
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
