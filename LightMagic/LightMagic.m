#import "LMCollector.h"
#import "LightMagic.h"
#import "LMClass.h"

__attribute__((constructor)) static void __unused initialize(void) {
    NSSet *classes = [LMCollector classesForProtocol:@protocol(LightMagic)];
    for (LMClass *clazz in classes) {
        [clazz injectGetters];
    }
}
