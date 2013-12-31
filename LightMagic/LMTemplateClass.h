#import <Foundation/Foundation.h>
#import <map>

@interface LMTemplateClass : NSObject

@end

extern id lm_dynamicGetter(LMTemplateClass *self, SEL _cmd);
extern void lm_class_addProperty(Class clazz, Class propertyClass, SEL getter);