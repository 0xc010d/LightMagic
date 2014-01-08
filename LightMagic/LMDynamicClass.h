#import <Foundation/Foundation.h>
#import "LMDefinitions.h"
#import "LMProtocolList.h"

@class LMProperty;

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class injectedClass;

- (instancetype)initWithContainerClass:(Class)containerClass;

- (void)addPropertyWithClass:(Class)propertyClass protocols:(LMProtocolList)propertyProtocols getter:(SEL)getter;

- (void)register;

@end