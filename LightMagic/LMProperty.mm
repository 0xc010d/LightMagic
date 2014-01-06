#import <objc/runtime.h>
#import <string>
#import <regex>
#import "LMProperty.h"

@implementation LMProperty {
    Class _clazz;
    LMProtocols _protocols;
    SEL _getter;
    BOOL _dynamic;
    objc_property_t _property;
}

- (void)dealloc {
    free(_protocols.list);
}

- (instancetype)initWithProperty:(objc_property_t)property {
    self = [super init];
    _property = property;
    [self parse];
    return self;
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
    return _clazz;
}

- (LMProtocols)protocols {
    return _protocols;
}

- (SEL)getter {
    return _getter;
}

- (BOOL)isInjectable {
    return _dynamic;
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
                size_t size = (_protocols.count + 1) * sizeof(Protocol *);
                _protocols.list = (Protocol __unsafe_unretained**)realloc(_protocols.list, size);
                _protocols.list[_protocols.count] = protocol;
                _protocols.count ++;
            }
            protocols = match.suffix().str();
        }
        type.erase(leftBracket, rightBracket - leftBracket);
    }
    _clazz = objc_getClass(type.c_str());
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && [object getter] == _getter;
}

- (NSUInteger)hash {
    return (NSUInteger)(void *)_getter;
}

@end
