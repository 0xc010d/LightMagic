#import <Foundation/Foundation.h>

@interface LMClass : NSObject

@property (nonatomic) BOOL shouldInjectGetters;

- (instancetype)initWithClass:(Class)clazz properties:(NSSet *)properties;
- (void)injectGetters;

@end