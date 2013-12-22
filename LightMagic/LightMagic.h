#import "LMContext.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMacroInspection"

#define LM_CONTEXT(group, block) __attribute__((constructor)) static void __unused group(void) { \
    @autoreleasepool { \
        block; \
    } \
}

#define LM_REGISTER_INITIALIZER(clazz, block) [LMContext registerInitializer:block forClass:[clazz class]]

#define LM_UNREGISTER_INITIALIZER(clazz) [LMContext removeInitializerForClass:[clazz class]]

#define LM_SINGLETON(clazz) \
    ^id (id sender) { \
        static id sharedInstance; \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            sharedInstance = [clazz new]; \
        }); \
        return sharedInstance; \
    }

#define LM_REGISTER_SINGLETON(clazz) LM_REGISTER_INITIALIZER(clazz, LM_SINGLETON(clazz))

#pragma clang diagnostic pop
