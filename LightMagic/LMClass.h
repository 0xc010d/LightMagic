#import <Foundation/Foundation.h>

@interface LMClass : NSObject

@property (nonatomic, readonly) BOOL shouldInjectGetters;

- (instancetype)initWithClass:(Class)clazz properties:(NSSet *)properties;
- (void)injectGetters;

@end