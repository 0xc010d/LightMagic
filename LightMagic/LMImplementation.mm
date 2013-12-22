#import <objc/message.h>
#import "LMImplementation.h"
#import "LMCache.h"

static id allocWithZone_(Class self, SEL __unused _cmd, NSZone *zone);
static void dealloc_(id self, SEL __unused _cmd);
static void dealloc(id self, SEL __unused _cmd);
static id dynamicGetter(id self, SEL _cmd);
static id forwardingGetter(id self, SEL _cmd);

IMP imp(SEL selector) {
    if (selector == LMSelectorAllocWithZone) {
        return (IMP)allocWithZone_;
    }
    else if (selector == LMSelectorDealloc) {
        return (IMP)dealloc_;
    }
    else if (selector == @selector(dealloc)) {
        return (IMP)dealloc;
    }
    return NULL;
}

IMP getter(BOOL forwarding) {
    return forwarding ? (IMP)forwardingGetter : (IMP)dynamicGetter;
}

id static allocWithZone_(Class self, SEL __unused _cmd, NSZone *zone) {
    id object = objc_msgSend(self, @selector(allocWithZone_:), zone);
    LMCache::getInstance().dynamicObjects[object] = [LMCache::getInstance().dynamicClasses[self] new];
    return object;
}

void static dealloc(id self, SEL __unused _cmd) {
    [LMCache::getInstance().dynamicObjects[self] release];
    LMCache::getInstance().dynamicObjects.erase(self);
}


void static dealloc_(id self, SEL __unused _cmd) {
    dealloc(self, _cmd);
    [self dealloc_];
}

id static dynamicGetter(id self, SEL _cmd) {
    id result;
    const char *name = sel_getName(_cmd);
    object_getInstanceVariable(self, name, (void **)&result);
    if (!result) {
        objc_property_t property = class_getProperty(object_getClass(self), name);
        const char *attributes = property_getAttributes(property);
        size_t len = strlen(attributes) - 4;
        char buffer[len + 1];
        memcpy(buffer, attributes + 3, len);
        buffer[len] = '\0';
        Class clazz = objc_getClass(buffer);
        LMInitializer initializer = LMCache::getInstance().initializer(clazz);
        result = initializer ? objc_msgSend(initializer(), @selector(retain)) : objc_msgSend(clazz, @selector(new));
        object_setInstanceVariable(self, name, result);
    }
    return result;
}

id static forwardingGetter(id self, SEL _cmd) {
    return objc_msgSend(LMCache::getInstance().dynamicObjects[self], _cmd);
}
