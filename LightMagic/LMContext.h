#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMContext : NSObject

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz;
+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz containerClass:(Class)containerClass;

+ (void)unregisterInitializerForClass:(Class)clazz;
+ (void)unregisterInitializerForClass:(Class)clazz containerClass:(Class)containerClass;

@end
