#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "LMProtocolList.h"

@interface LMProperty : NSObject

@property (nonatomic, readonly) Class clazz;
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) LMProtocolList protocols;

@property (nonatomic, readonly, getter=isInjectable) BOOL injectable;

- (instancetype)initWithProperty:(objc_property_t)property;

@end