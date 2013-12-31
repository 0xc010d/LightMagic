#import <Foundation/Foundation.h>

@interface LMTemplateClass : NSObject

@end

extern void lm_class_addProperty(Class clazz, Class propertyClass, SEL getter);