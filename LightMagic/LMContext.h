#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMContext : NSObject

+ (void)registerInitializer:(LMInitializerBlock)initializer forClass:(Class)propertyClass;
+ (void)registerInitializer:(LMInitializerBlock)initializer in:(Class)containerClass forClass:(Class)propertyClass;
+ (void)registerInitializer:(LMInitializerBlock)initializer in:(Class)containerClass forClass:(Class)propertyClass protocols:(NSArray *)protocols;

+ (void)unregisterInitializerForClass:(Class)propertyClass;
+ (void)unregisterInitializerForClass:(Class)propertyClass containerClass:(Class)containerClass;

@end
