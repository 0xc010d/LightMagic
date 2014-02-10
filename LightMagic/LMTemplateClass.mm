#import <objc/runtime.h>
#import <objc/message.h>

#import "LMTemplateClass.h"

#include "LMCache.h"

id static dynamicGetter(LMTemplateClass *self, SEL _cmd);
Class static property_getClass(objc_property_t property);

@implementation LMTemplateClass {
    @public
    std::map<SEL, id> _values;
}

- (void)dealloc {
    for (auto& value : _values) {
        [value.second release];
    }
    [super dealloc];
}

@end

void lm_class_addProperty(Class objcClass, SEL getter, LMInitializerDescriptor descriptor) {
    const char *name = sel_getName(getter);
    const char *typeString = descriptor.type.str().c_str();
    objc_property_attribute_t attributes[] = {"T", typeString};
    class_addProperty(objcClass, name, attributes, 1);
    class_addMethod(objcClass, getter, (IMP) dynamicGetter, "@@:");
    //cache initializer
    LMCache& cache = LMCache::getInstance();
    LMInitializerBlock initializer = cache.initializer(descriptor);
    cache.initializerCache[objcClass][getter] = initializer;
    cache.getterCache[descriptor.type][objcClass].insert(getter);
}

#pragma mark - Private

id static dynamicGetter(LMTemplateClass *self, SEL _cmd) {
    id result = self->_values[_cmd];
    if (!result) {
        Class injectedClass = object_getClass(self);
        LMInitializerBlock initializer = LMCache::getInstance().initializerCache[injectedClass][_cmd];
        if (initializer) {
            id container = LMCache::getInstance().injectedObjects.reversed()[self];
            result = objc_msgSend(initializer(container), @selector(retain));
        }
        else {
            const char *name = sel_getName(_cmd);
            objc_property_t property = class_getProperty(injectedClass, name);
            Class propertyClass = property_getClass(property);
            result = objc_msgSend(propertyClass, @selector(new));
        }
        self->_values[_cmd] = result;
    }
    return result;
}

Class static property_getClass(objc_property_t property) {
    const char *type = property_getAttributes(property) + 1;
    LMTypeDescriptor descriptor(type);
    return descriptor.objcClass;
}
