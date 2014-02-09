#import <objc/runtime.h>

#include <string>
#include <regex>

#import "LMProperty.h"
#import "LMDefinitions.h"

@implementation LMProperty {
    SEL _getter;
    BOOL _dynamic;
    objc_property_t _property;
    LMPropertyDescriptor _descriptor;
}

- (LMPropertyDescriptor)descriptor {
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

- (Class)clazz {
    return _descriptor.propertyClass;
}

- (SEL)getter {
    return _getter;
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
                [self parsePropertyType:value];
            }
        } break;
        default:
            break;
    }
}

- (void)parsePropertyType:(const char *)typeString {
    std::string type = std::string(typeString + 1);
    type.erase(std::remove(type.begin(), type.end(), '"'), type.end());
    size_t leftBracket = type.find('<');
    if (leftBracket != std::string::npos) {
        size_t rightBracket = type.rfind('>') + 1;

        std::regex regex("<(.+?)>");
        std::smatch match;
        std::string protocols = type.substr(leftBracket, rightBracket - leftBracket);
        while (std::regex_search(protocols, match, regex)) {
            const char *name = match[1].str().c_str();
            Protocol *protocol = objc_getProtocol(name);
            if (protocol) {
                _descriptor.protocols.insert(protocol);
            }
            protocols = match.suffix().str();
        }
        type.erase(leftBracket, rightBracket - leftBracket);
    }
    _descriptor.propertyClass = objc_getClass(type.c_str());
}

@end
