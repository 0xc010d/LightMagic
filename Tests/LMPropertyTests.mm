#import <Kiwi.h>
#import "LMProperty.h"
#import "LMPropertiesParserTest.h"

objc_property_t static getPropertyByName(Class clazz, const char *targetName) {
    objc_property_t result = NULL;
    uint propertiesCount;
    objc_property_t *properties = class_copyPropertyList(clazz, &propertiesCount);
    for (uint i = 0; i < propertiesCount; i ++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        if (strcmp(propertyName, targetName) == 0) {
            result = property;
            break;
        }
    }
    free(properties);
    return result;
}

SPEC_BEGIN(LMPropertyTests)
        context(@"Injectability detecting", ^{
            it(@"Should detect synthesized property", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "synthesizedProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[theValue([property isInjectableInClass:[LMPropertiesParserTest class]]) should] equal:theValue(NO)];
            });
            it(@"Should detect injectable property", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "dynamicProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[theValue([property isInjectableInClass:[LMPropertiesParserTest class]]) should] equal:theValue(YES)];
            });
        });
        context(@"Type parser", ^{
            it(@"Should not not return class if property type is id", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "idProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass should] beNil];
            });
            it(@"Should detect class if it's specified", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "classProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass should] equal:[NSObject class]];
            });
            it(@"Should skip non-existent class", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "nonExistentClassProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass should] beNil];
            });
            it(@"Should skip non-existent protocol", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "nonExistentProtocolProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[theValue(property.descriptor.protocols.size()) should] equal:theValue(1)];
                [[*property.descriptor.protocols.begin() should] equal:@protocol(NSObject)];
            });
            it(@"Should detect protocol if it's specified and property type is id", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "idProtocolProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass should] beNil];
                [[theValue(property.descriptor.protocols.size()) should] equal:theValue(1)];
                [[*property.descriptor.protocols.begin() should] equal:@protocol(NSObject)];
            });
            it(@"Should detect multiple protocols if they're specified and property type is id", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "idProtocolsProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass should] beNil];
                std::set<id> protocols = property.descriptor.protocols;
                [[theValue(protocols.size()) should] equal:theValue(2)];
                [[theValue(protocols.find(@protocol(UITableViewDelegate)) != protocols.end()) should] equal:theValue(true)];
                [[theValue(protocols.find(@protocol(UITableViewDataSource)) != protocols.end()) should] equal:theValue(true)];
            });
            it(@"Should detect protocol and property class if they're specified", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "classProtocolProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass shouldNot] beNil];
                [[theValue(property.descriptor.protocols.size()) should] equal:theValue(1)];
                [[*property.descriptor.protocols.begin() should] equal:@protocol(NSCopying)];
            });
            it(@"Should detect multiple protocols and property class if they're specified", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "classProtocolsProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[property.descriptor.propertyClass shouldNot] beNil];
                std::set<id> protocols = property.descriptor.protocols;
                [[theValue(protocols.size()) should] equal:theValue(2)];
                [[theValue(protocols.find(@protocol(UITableViewDelegate)) != protocols.end()) should] equal:theValue(true)];
                [[theValue(protocols.find(@protocol(UITableViewDataSource)) != protocols.end()) should] equal:theValue(true)];
            });
        });
        context(@"Getter detecting", ^{
            it(@"Should detect default getter", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "defaultGetterProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[theValue(property.getter) should] equal:theValue(@selector(defaultGetterProperty))];
            });
            it(@"Should detect custom getter", ^{
                objc_property_t rawProperty = getPropertyByName([LMPropertiesParserTest class], "customGetterProperty");
                LMProperty *property = [[LMProperty alloc] initWithProperty:rawProperty];
                [[theValue(property.getter) should] equal:theValue(@selector(customGetter))];
            });
        });
SPEC_END