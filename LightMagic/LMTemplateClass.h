#import <Foundation/Foundation.h>
#import <map>

@interface LMTemplateClass : NSObject

@end

extern id lm_dynamicGetter(LMTemplateClass *self, SEL _cmd);
extern objc_property_attribute_t (*lm_propertyAttributesForClass(Class clazz, uint *count));
