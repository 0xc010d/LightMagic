#import <Foundation/Foundation.h>


@interface LMClass : NSObject

- (instancetype)initWithClass:(Class)clazz;
- (void)injectGetters;

@end