#import "LMContext.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMacroInspection"

#define inject(property) @dynamic property; \
+ (void)__inject_##property __unavailable {}

#define LM_CONTEXT(group, block) \
    __attribute__((constructor(1000))) static void __used group(void) { \
        @autoreleasepool { \
            block \
        } \
    }

#define LM_REGISTER_INITIALIZER(propertyClass, block) \
    [LMContext registerInitializer:block forClass:[propertyClass class]]

#define LM_REGISTER_CONTAINER_INITIALIZER(propertyClass, container, block) \
    [LMContext registerInitializer:block in:[container class] forClass:[propertyClass class]]

#define LM_UNREGISTER_INITIALIZER(propertyClass) \
    [LMContext unregisterInitializerForClass:[propertyClass class]]

#define LM_UNREGISTER_CONTAINER_INITIALIZER(propertyClass, container) \
    [LMContext unregisterInitializerForClass:[propertyClass class] containerClass:[container class]]

#define LM_SINGLETON(clazz) \
    ^id (id sender) { \
        __used static id sharedInstance; \
        __used static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            sharedInstance = [clazz new]; \
        }); \
        return sharedInstance; \
    }

#define LM_REGISTER_SINGLETON(propertyClass) \
    LM_REGISTER_INITIALIZER(propertyClass, LM_SINGLETON(propertyClass))

#define LM_REGISTER_CONTAINER_SINGLETON(propertyClass, container) \
    LM_REGISTER_CONTAINER_INITIALIZER(propertyClass, container, LM_SINGLETON(propertyClass))

#pragma clang diagnostic pop
