#import <Foundation/Foundation.h>

#import "LMDefinitions.h"

#include "LMPropertyDescriptor.h"

@interface LMTemplateClass : NSObject

@end

void lm_class_addProperty(Class objcClass, SEL getter, LMPropertyDescriptor descriptor);
