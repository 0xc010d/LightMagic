#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

#include "LMInitializerDescriptor.h"

@class LMProperty;

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class injectedClass;

- (instancetype)initWithContainerClass:(Class)containerClass;

- (void)addPropertyWithDescriptor:(LMInitializerDescriptor)descriptor getter:(SEL)getter;

- (void)register;

@end