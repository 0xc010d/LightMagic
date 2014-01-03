#import "LMCollector.h"
#import "LightMagic.h"
#import "LMClass.h"

__attribute__((constructor(10000))) static void __unused initialize(void) {
    NSSet *classes = [LMCollector classesForProtocol:@protocol(LightMagic)];
    for (LMClass *clazz in classes) {
        if (clazz.shouldInjectGetters) {
            [clazz injectGetters];
        }
    }
}
