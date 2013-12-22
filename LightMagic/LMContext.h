#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMContext : NSObject

+ (void)registerInitializer:(LMInitializer)initializer forClass:(Class)clazz;

+ (void)removeInitializerForClass:(Class)clazz;

@end
