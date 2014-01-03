#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class clazz;

#if LM_FORCED_CACHE
- (instancetype)initWithContainerClass:(Class)containerClass;
#else
- (instancetype)initWithBaseName:(const char *)baseName;
#endif

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector;

- (void)register;

@end