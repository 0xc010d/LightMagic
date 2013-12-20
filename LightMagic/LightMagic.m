#import "LMCollector.h"
#import "LightMagic.h"
#import "LMClass.h"

__attribute__((constructor(10000))) static void __unused setInitializers(void) {
    NSSet *classes = [LMCollector classesForProtocol:@protocol(LightMagic)];
    for (LMClass *clazz in classes) {
        [clazz injectGetters];
    }
}