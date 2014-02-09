#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "LMPropertyDescriptor.h"

@interface LMProperty : NSObject

@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) LMPropertyDescriptor descriptor;

- (instancetype)initWithProperty:(objc_property_t)property;

- (BOOL)isInjectableInClass:(Class)objcClass;

@end