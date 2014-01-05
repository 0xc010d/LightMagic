#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMTemplateClass : NSObject

@end

void lm_class_addProperty(Class injectedClass, Class propertyClass, SEL getter);
