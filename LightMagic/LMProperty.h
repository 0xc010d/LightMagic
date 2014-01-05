#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <set>

@interface LMProperty : NSObject

@property (nonatomic, readonly) Class clazz;
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) std::set<id> protocols; // std::set<Protocol *>

@property (nonatomic, readonly, getter=isInjectable) BOOL injectable;

- (instancetype)initWithProperty:(objc_property_t)property;

@end