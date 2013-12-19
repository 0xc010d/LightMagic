#import <Foundation/Foundation.h>

@interface LMContext : NSObject

+ (instancetype)defaultContext;

- (void)setInitializer:(id (^)(void))initializer forClass:(Class)clazz;
- (id (^)(void))initializerForClass:(Class)clazz;

@end
