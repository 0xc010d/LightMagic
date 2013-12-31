#import <objc/runtime.h>
#import <objc/message.h>
#import "LMTemplateClass.h"
#import "LMDefinitions.h"
#import "LMCache.h"

static Class lm_property_getClass(objc_property_t property);

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

id lm_dynamicGetter(LMTemplateClass *self, SEL _cmd) {
    id result = self->values[_cmd];
    if (!result) {
        const char *name = sel_getName(_cmd);
        objc_property_t property = class_getProperty(object_getClass(self), name);
        Class clazz = lm_property_getClass(property);
        LMInitializer initializer = LMCache::getInstance().initializer(clazz);
        if (initializer) {
            id sender = LMCache::getInstance().reversedObjects[self];
            result = objc_msgSend(initializer(sender), @selector(retain));
        }
        else {
            result = objc_msgSend(clazz, @selector(new));
        }
        self->values[_cmd] = result;
    }
    return result;
}

void lm_class_addProperty(Class clazz, Class propertyClass, SEL getter) {
    const char *name = sel_getName(getter);
    const char *className = class_getName(propertyClass);
    objc_property_attribute_t attributes[] = {"T", className};
    class_addProperty(clazz, name, attributes, 1);
    class_addMethod(clazz, getter, (IMP)lm_dynamicGetter, "@@:");
}

Class static lm_property_getClass(objc_property_t property) {
    const char *className = property_getAttributes(property) + 1;
    return objc_getClass(className);
}
