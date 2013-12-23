#import <Foundation/Foundation.h>

@interface LMCollector : NSObject

+ (NSSet *)classesForProtocol:(Protocol *)protocol;
+ (NSSet *)injectablePropertiesForClass:(Class)clazz protocol:(Protocol *)protocol;

@end
