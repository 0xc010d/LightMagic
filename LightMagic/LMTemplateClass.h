#import <Foundation/Foundation.h>
#import "LMDefinitions.h"

@interface LMTemplateClass : NSObject

@end

#if LM_FORCED_CACHE
extern void lm_class_addProperty(Class containerClass, Class dynamicClass, Class propertyClass, SEL getter);
#else
void lm_class_addProperty(Class dynamicClass, Class propertyClass, SEL getter);
#endif
