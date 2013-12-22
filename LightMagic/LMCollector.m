#import <objc/runtime.h>
#import "LMCollector.h"
#import "LMClass.h"

@implementation LMCollector

+ (NSSet *)classesForProtocol:(Protocol *)protocol {
    NSMutableSet *result = [NSMutableSet set];

    uint classesCount;
    char const *imageName = class_getImageName(object_getClass(self));
    const char **classNames = objc_copyClassNamesForImage(imageName, &classesCount);

    for (uint index = 0; index < classesCount; index++) {
        Class nextClass = objc_getClass(classNames[index]);
        if (class_conformsToProtocol(nextClass, protocol)) {
            LMClass *clazz = [[LMClass alloc] initWithClass:nextClass protocol:protocol];
            [result addObject:clazz];
        }
    }

    free(classNames);

    return [NSSet setWithSet:result];
}

@end
