#import <Foundation/Foundation.h>
#import "LMDefinitions.h"
#import "LMProtocolsList.h"

@interface LMTemplateClass : NSObject

@end

void lm_class_addProperty(Class injectedClass, Class containerClass, Class propertyClass, LMProtocolsList propertyProtocols, SEL getter);
