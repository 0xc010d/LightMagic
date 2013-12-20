#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <objc/runtime.h>
#import "LMCollector.h"
#import "LMClass.h"

@implementation LMCollector

+ (NSSet *)classesForProtocol:(Protocol *)protocol {
    NSMutableSet *result = [NSMutableSet set];

    Dl_info info;
    dladdr(&_mh_execute_header, &info);

    uint classesCount;
    const char **classNames = objc_copyClassNamesForImage(info.dli_fname, &classesCount);

    for (uint index = 0; index < classesCount; index++) {
        Class nextClass = objc_getClass(classNames[index]);
        if (class_conformsToProtocol(nextClass, protocol)) {
            LMClass *clazz = [[LMClass alloc] initWithClass:nextClass];
            [result addObject:clazz];
        }
    }

    free(classNames);

    return [NSSet setWithSet:result];
}

@end
