#import <Foundation/Foundation.h>
#import <set>
#import "LMDefinitions.h"

@class LMProperty;

@interface LMDynamicClass : NSObject

@property (nonatomic, readonly) Class injectedClass;

- (instancetype)initWithBaseName:(const char *)baseName;

- (void)addProperty:(LMProperty *)property;

- (void)register;

@end