#import <objc/runtime.h>
#import "LMProperty.h"

@implementation LMProperty {
    Class _clazz;
    SEL _getter;
    BOOL _dynamic;
    objc_property_t _property;
}

- (instancetype)initWithProperty:(objc_property_t)property {
    self = [super init];
    _property = property;
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
            //it's something like @"NSObject" so we need to get just NSObject from it
            //we don't support protocols. yet.
            const char *value = attribute.value;
            size_t len = strlen(value) - 3;
            char buffer[len + 1];
            memcpy(buffer, value + 2, len);
            buffer[len] = '\0';
            _clazz = objc_getClass(buffer);
        } break;
        default:
            break;
    }
}

@end
