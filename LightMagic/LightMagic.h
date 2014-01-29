#import "LMContext.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMacroInspection"

#define inject(property) @dynamic property; \
+ (void)$__inject_##property __unavailable {}

#define LM_CONTEXT(group, block) \
    __attribute__((constructor(1000))) static void __used group(void) { \
        @autoreleasepool { \
            block; \
        } \
    }

#define LM_REGISTER_INITIALIZER(clazz, block) [LMContext registerInitializer:block forClass:[clazz class]]

#define LM_REGISTER_CONTAINER_INITIALIZER(property, container, block) \
    [LMContext registerInitializer:block forClass:[property class] containerClass:[container class]]

#define LM_UNREGISTER_INITIALIZER(clazz) [LMContext unregisterInitializerForClass:[clazz class]]

#define LM_UNREGISTER_CONTAINER_INITIALIZER(property, container) \
    [LMContext unregisterInitializerForClass:[property class] containerClass:[container class]]

#define LM_SINGLETON(clazz) \
    ^id (id sender) { \
        __used static id sharedInstance; \
        __used static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            sharedInstance = [clazz new]; \
        }); \
        return sharedInstance; \
    }

#define LM_REGISTER_SINGLETON(clazz) LM_REGISTER_INITIALIZER(clazz, LM_SINGLETON(clazz))

#define LM_REGISTER_CONTAINER_SINGLETON(property, container) \
    LM_REGISTER_CONTAINER_INITIALIZER(property, container, LM_SINGLETON(property))

#pragma clang diagnostic pop
