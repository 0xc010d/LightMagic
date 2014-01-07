#import <Foundation/Foundation.h>
#import "LMDefinitions.h"
#import "LMProtocolsList.h"

@class LMProperty;

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class injectedClass;

- (instancetype)initWithContainerClass:(Class)containerClass;

- (void)addPropertyWithClass:(Class)propertyClass protocols:(LMProtocolsList)propertyProtocols getter:(SEL)getter;

- (void)register;

@end