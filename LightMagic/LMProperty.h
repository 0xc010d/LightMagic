#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "LMInitializerDescriptor.h"

@interface LMProperty : NSObject

@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) LMInitializerDescriptor descriptor;

- (instancetype)initWithProperty:(objc_property_t)property;

- (BOOL)isInjectableInClass:(Class)objcClass;

@end