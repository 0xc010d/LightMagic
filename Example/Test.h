#import <Foundation/Foundation.h>

@interface Test : NSObject

@property (nonatomic, strong) id<NSObject> lazyObject;
@property (nonatomic, strong) NSObject *associatedObject;
@property (nonatomic, strong) NSObject *ivarObject;

@end
