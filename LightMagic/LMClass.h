#import <Foundation/Foundation.h>

@interface LMClass : NSObject

@property (nonatomic, readonly) BOOL shouldInjectGetters;

- (instancetype)initWithClass:(Class)containerClass properties:(NSSet *)properties;
- (void)injectGetters;

@end