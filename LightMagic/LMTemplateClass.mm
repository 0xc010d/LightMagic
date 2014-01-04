#import <map>
#import <objc/runtime.h>
#import <objc/message.h>
#import "LMTemplateClass.h"
#import "LMCache.h"

id static lm_dynamicGetter(LMTemplateClass *self, SEL _cmd);
Class static lm_property_getClass(objc_property_t property);

@implementation LMTemplateClass {
    @public
    std::map<SEL, id> values;
}

- (void)dealloc {
    for (std::map<SEL, id>::iterator iterator = values.begin(); iterator != values.end(); iterator++) {
        [iterator->second release];
    }
    [super dealloc];
}

@end

void lm_class_addProperty(Class dynamicClass, Class propertyClass, SEL getter) {
    const char *name = sel_getName(getter);
    const char *className = class_getName(propertyClass);
    objc_property_attribute_t attributes[] = {"T", className};
    class_addProperty(dynamicClass, name, attributes, 1);
    class_addMethod(dynamicClass, getter, (IMP)lm_dynamicGetter, "@@:");
}

#pragma mark - Private

id static lm_dynamicGetter(LMTemplateClass *self, SEL _cmd) {
    id result = self->values[_cmd];
    if (!result) {
        const char *name = sel_getName(_cmd);
        Class dynamicClass = object_getClass(self);
        objc_property_t property = class_getProperty(dynamicClass, name);
        Class propertyClass = lm_property_getClass(property);
        BOOL hasDefaultInitializer;
        BOOL hasContainerInitializer = LMCache::getInstance().hasContainerInitializers(propertyClass, &hasDefaultInitializer);
        if (hasContainerInitializer) {
            id container = LMCache::getInstance().containerObjects[self];
            Class containerClass = object_getClass(container);
            LMInitializer initializer = LMCache::getInstance().initializer(propertyClass, containerClass);
            if (initializer) {
                result = objc_msgSend(initializer(container), @selector(retain));
            }
            else {
                result = objc_msgSend(propertyClass, @selector(new));
            }
        }
        else if (hasDefaultInitializer) {
            LMInitializer initializer = LMCache::getInstance().initializer(propertyClass);
            id container = LMCache::getInstance().containerObjects[self];
            result = objc_msgSend(initializer(container), @selector(retain));
        }
        else {
            result = objc_msgSend(propertyClass, @selector(new));
        }
        self->values[_cmd] = result;
    }
    return result;
}

Class static lm_property_getClass(objc_property_t property) {
    const char *className = property_getAttributes(property) + 1;
    return objc_getClass(className);
}
