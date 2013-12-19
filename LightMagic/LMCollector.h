#import <Foundation/Foundation.h>

@interface LMCollector : NSObject

+ (NSSet *)classesForProtocol:(Protocol *)protocol;

@end
