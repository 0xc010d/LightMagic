#import "LMCollector.h"
#import "LMClass.h"
#import <objc/runtime.h>

@implementation LMCollector

+ (NSSet *)classesForProtocol:(Protocol *)protocol{
    NSMutableSet *result = [NSMutableSet set];
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0 ) {
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int index = 0; index < numClasses; index++) {
            Class nextClass = classes[index];
            if (class_conformsToProtocol(nextClass, protocol)) {
                LMClass *clazz = [[LMClass alloc] initWithClass:nextClass];
                [result addObject:clazz];
            }
        }
        free(classes);
    }
    return [NSSet setWithSet:result];
}

@end
