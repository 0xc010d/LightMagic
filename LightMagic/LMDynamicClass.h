#import <Foundation/Foundation.h>


@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class clazz;

- (instancetype)initWithBaseName:(const char *)baseName;

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector;

- (void)register;

@end