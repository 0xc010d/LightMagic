#import <Foundation/Foundation.h>
#import "LMDefinitions.h"
#import "LMProtocolList.h"
#import "LMPropertyDescriptor.h"

@class LMProperty;

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class injectedClass;

- (instancetype)initWithContainerClass:(Class)containerClass;

- (void)addPropertyWithDescriptor:(LMPropertyDescriptor)descriptor getter:(SEL)getter;

- (void)register;

@end