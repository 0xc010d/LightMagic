#import <objc/runtime.h>

#include <string>
#include <regex>

#import "LMProperty.h"
#import "LMDefinitions.h"

@implementation LMProperty {
    SEL _getter;
    BOOL _dynamic;
    objc_property_t _property;
    LMInitializerDescriptor _descriptor;
}

- (SEL)getter {
    return _getter;
}

- (LMInitializerDescriptor)descriptor {
    return _descriptor;
}

- (instancetype)initWithProperty:(objc_property_t)property {
    self = [super init];
    _property = property;
    [self parse];
    return self;
}

- (BOOL)isInjectableInClass:(Class)objcClass {
    if (!_dynamic) {
        return NO;
    }
    const char *propertyName = property_getName(_property);
    char *selectorName = (char *)malloc(strlen(kLMInjectPrefix) + strlen(propertyName) + 1);
    strcpy(selectorName, kLMInjectPrefix);
    strcat(selectorName, propertyName);
    SEL selector = sel_getUid(selectorName);
    free(selectorName);
    Class metaClass = object_getClass((id)objcClass);
    return class_respondsToSelector(metaClass, selector);
}

- (void)parse {
    uint attributesCount = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(_property, &attributesCount);
    for (int attributeIndex = 0; attributeIndex < attributesCount; attributeIndex++) {
        objc_property_attribute_t attribute = attributes[attributeIndex];
        [self parsePropertyAttribute:attribute];
    }
    free(attributes);
    if (!_getter) {
        _getter = sel_getUid(property_getName(_property));
    }
}

#pragma mark - Private

- (void)parsePropertyAttribute:(objc_property_attribute_t)attribute {
    switch (attribute.name[0]) {
        case 'D':
            _dynamic = YES;
            break;
        case 'G':
            _getter = sel_getUid(attribute.value);
            break;
        case 'T': {
            const char *value = attribute.value;
            if (value[0] == '@' && strlen(value) > 1) {
                _descriptor.type.parse(value);
            }
        } break;
        default:
            break;
    }
}

@end
