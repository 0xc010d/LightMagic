#import <objc/runtime.h>
#import <objc/message.h>
#import "LMTemplateClass.h"
#import "LMDefinitions.h"
#import "LMCache.h"

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
        const char *className = property_getAttributes(property) + 1;
        Class clazz = objc_getClass(className);
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

objc_property_attribute_t *lm_propertyAttributesForClass(Class clazz, uint *count) {
    const char *className = class_getName(clazz);
    static objc_property_attribute_t attributes[] = {"T", className};
    *count = 1;
    return attributes;
}
