#import <Foundation/Foundation.h>
#import "LMDefinitions.h"
#import "LMProtocolList.h"

@interface LMTemplateClass : NSObject

@end

void lm_class_addProperty(Class injectedClass, Class containerClass, Class propertyClass, LMProtocolList propertyProtocols, SEL getter);
