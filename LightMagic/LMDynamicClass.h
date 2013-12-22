#import <Foundation/Foundation.h>


@interface LMDynamicClass : NSObject

- (instancetype)initForClass:(Class)clazz properties:(NSSet *)properties; //NSSet of LMProperty

- (void)createAndInject;

@end