#import <objc/runtime.h>
#import <objc/message.h>
#import "LMTemplateClass.h"
#include "LMCache.h"

id static lm_dynamicGetter(LMTemplateClass *self, SEL _cmd);
Class static lm_property_getClass(objc_property_t property);

@implementation LMTemplateClass {
    @public
    std::map<SEL, id> values;
}

- (void)dealloc {
    for (auto iterator = values.begin(); iterator != values.end(); iterator++) {
        [iterator->second release];
    }
    [super dealloc];
}

@end

void lm_class_addProperty(Class injectedClass, Class containerClass, Class propertyClass, LMProtocolList __unused propertyProtocols, SEL getter) {
    const char *name = sel_getName(getter);
    const char *className = class_getName(propertyClass);
    objc_property_attribute_t attributes[] = {"T", className};
    class_addProperty(injectedClass, name, attributes, 1);
    class_addMethod(injectedClass, getter, (IMP)lm_dynamicGetter, "@@:");
    //cache initializer
    LMInitializer initializer = LMCache::getInstance().initializer(propertyClass, containerClass);
    LMCache::getInstance().initializerCache[injectedClass][getter] = initializer;
    LMCache::getInstance().getterCache[propertyClass][injectedClass].insert(getter);
}

#pragma mark - Private

id static lm_dynamicGetter(LMTemplateClass *self, SEL _cmd) {
    id result = self->values[_cmd];
    if (!result) {
        Class injectedClass = object_getClass(self);
        LMInitializer initializer = LMCache::getInstance().initializerCache[injectedClass][_cmd];
        if (initializer) {
            id container = LMCache::getInstance().injectedObjects.reversed()[self];
            result = objc_msgSend(initializer(container), @selector(retain));
        }
        else {
            const char *name = sel_getName(_cmd);
            objc_property_t property = class_getProperty(injectedClass, name);
            Class propertyClass = lm_property_getClass(property);
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
