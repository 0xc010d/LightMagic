#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface LMProperty : NSObject

- (instancetype)initWithProperty:(objc_property_t)property;

@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, strong, readonly) id (^initializer)(void);

@property (nonatomic, readonly, getter=isInjectable) BOOL injectable;

@end