#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface LMProperty : NSObject

@property (nonatomic, readonly) Class clazz;
@property (nonatomic, readonly) SEL getter;

@property (nonatomic, readonly, getter=isInjectable) BOOL injectable;

- (instancetype)initWithProperty:(objc_property_t)property;
- (void)parse;

@end