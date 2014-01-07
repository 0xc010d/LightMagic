#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMContext : NSObject

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)propertyClass;
+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)propertyClass containerClass:(Class)containerClass;

+ (void)unregisterInitializerForClass:(Class)propertyClass;
+ (void)unregisterInitializerForClass:(Class)propertyClass containerClass:(Class)containerClass;

@end
