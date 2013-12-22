#import <Foundation/Foundation.h>

@interface LMClass : NSObject

- (instancetype)initWithClass:(Class)clazz protocol:(Protocol *)protocol;
- (void)injectGetters;

@end