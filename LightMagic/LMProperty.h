#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef struct LMProtocols {
    uint count;
    Protocol  __unsafe_unretained**list;
} LMProtocols;

@interface LMProperty : NSObject

@property (nonatomic, readonly) Class clazz;
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) LMProtocols protocols;

@property (nonatomic, readonly, getter=isInjectable) BOOL injectable;

- (instancetype)initWithProperty:(objc_property_t)property;

@end