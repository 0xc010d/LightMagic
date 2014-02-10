#import <Kiwi.h>
#import "LMTypeDescriptor.h"

SPEC_BEGIN(LMTypeDescriptorTests)
        context(@"Constructor", ^{
            it(@"Should properly handle default values", ^{
                LMTypeDescriptor descriptor;
                [[descriptor.objcClass should] beNil];
                [[theValue(descriptor.protocols.size()) should] equal:theValue(0)];
            });
        });
        context(@"Parser", ^{
            __block LMTypeDescriptor *descriptor;
            beforeEach(^{
                descriptor = new LMTypeDescriptor;
            });
            afterEach(^{
                delete descriptor;
            });
            it(@"Should parse id type", ^{
                descriptor->parse("@");
                [[descriptor->objcClass should] beNil];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(0)];
            });
            it(@"Should parse class only type", ^{
                descriptor->parse("@\"NSObject\"");
                [[descriptor->objcClass should] equal:[NSObject class]];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(0)];
            });
            it(@"Should not fail with nonexistent class type", ^{
                descriptor->parse("@\"NonExistentClass\"");
                [[descriptor->objcClass should] beNil];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(0)];
            });
            it(@"Should parse one protocol type", ^{
                descriptor->parse("@\"<NSObject>\"");
                [[descriptor->objcClass should] beNil];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(1)];
                [[theValue(descriptor->protocols.find(@protocol(NSObject))) shouldNot] equal:theValue(descriptor->protocols.end())];
            });
            it(@"Should parse multiple protocols type", ^{
                descriptor->parse("@\"<NSObject><NSCoding>\"");
                [[descriptor->objcClass should] beNil];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(2)];
                [[theValue(descriptor->protocols.find(@protocol(NSObject))) shouldNot] equal:theValue(descriptor->protocols.end())];
                [[theValue(descriptor->protocols.find(@protocol(NSCoding))) shouldNot] equal:theValue(descriptor->protocols.end())];
            });
            it(@"Should parse class with multiple protocols type", ^{
                descriptor->parse("@\"NSObject<NSObject><NSCoding>\"");
                [[descriptor->objcClass should] equal:[NSObject class]];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(2)];
                [[theValue(descriptor->protocols.find(@protocol(NSObject))) shouldNot] equal:theValue(descriptor->protocols.end())];
                [[theValue(descriptor->protocols.find(@protocol(NSCoding))) shouldNot] equal:theValue(descriptor->protocols.end())];
            });
            it(@"Should not fail with nonexistent protocol", ^{
                descriptor->parse("@\"NSObject<NonExistentProtocol><NSCopying>\"");
                [[descriptor->objcClass should] equal:[NSObject class]];
                [[theValue(descriptor->protocols.size()) should] equal:theValue(1)];
                [[theValue(descriptor->protocols.find(@protocol(NSCopying))) shouldNot] equal:theValue(descriptor->protocols.end())];
            });
        });
        context(@"Serializer", ^{
            __block LMTypeDescriptor *descriptor;
            beforeEach(^{
                descriptor = new LMTypeDescriptor;
            });
            afterEach(^{
                delete descriptor;
            });
            it(@"Should serialize empty descriptor", ^{
                [[@(descriptor->str().c_str()) should] equal:@"@"];
            });
            it(@"Should serialize class only descriptor", ^{
                descriptor->objcClass = [NSObject class];
                [[@(descriptor->str().c_str()) should] equal:@"@\"NSObject\""];
            });
            it(@"Should serialize one protocol descriptor", ^{
                descriptor->protocols.insert(@protocol(NSObject));
                [[@(descriptor->str().c_str()) should] equal:@"@\"<NSObject>\""];
            });
            it(@"Should serialize multiple protocols descriptor", ^{
                descriptor->protocols.insert(@protocol(NSObject));
                descriptor->protocols.insert(@protocol(NSCoding));

                NSString *descriptorString = @(descriptor->str().c_str());
                [[descriptorString should] containString:@"<NSObject>"];
                [[descriptorString should] containString:@"<NSCoding>"];
                [[theValue([descriptorString hasPrefix:@"@\""]) should] equal:theValue(YES)];
                [[theValue([descriptorString hasSuffix:@"\""]) should] equal:theValue(YES)];
                [[theValue(descriptor->str().size()) should] equal:theValue([@"@\"<NSObject><NSCoding>\"" length])];
            });
            it(@"Should serialize class with multiple protocols descriptor", ^{
                descriptor->objcClass = [NSObject class];
                descriptor->protocols.insert(@protocol(NSCopying));
                descriptor->protocols.insert(@protocol(NSCoding));
                NSString *descriptorString = @(descriptor->str().c_str());
                [[descriptorString should] containString:@"NSObject"];
                [[descriptorString should] containString:@"<NSCopying>"];
                [[descriptorString should] containString:@"<NSCoding>"];
                [[theValue([descriptorString hasPrefix:@"@\""]) should] equal:theValue(YES)];
                [[theValue([descriptorString hasSuffix:@"\""]) should] equal:theValue(YES)];
                [[theValue(descriptor->str().size()) should] equal:theValue([@"@\"NSObject<NSCopying><NSCoding>\"" length])];
            });
        });
        context(@"Equality operator", ^{
            it(@"Should work on empty objects", ^{
                LMTypeDescriptor descriptor1;
                LMTypeDescriptor descriptor2;
                [[theValue(descriptor1 == descriptor2) should] equal:theValue(true)];
            });
            it(@"Should work on non-empty equal objects", ^{
                LMTypeDescriptor descriptor1("@\"NSObject<NSCoding><NSCopying>\"");
                LMTypeDescriptor descriptor2("@\"NSObject<NSCoding><NSCopying>\"");
                [[theValue(descriptor1 == descriptor2) should] equal:theValue(true)];
            });
            it(@"Should work on non-empty non-equal objects", ^{
                LMTypeDescriptor descriptor1("@\"NSObject<NSCoding><NSCopying>\"");
                LMTypeDescriptor descriptor2("@\"NSObject<NSCoding>\"");
                [[theValue(descriptor1 == descriptor2) should] equal:theValue(false)];
            });
        });
        context(@"Non-equality operator", ^{
            it(@"Should work on empty objects", ^{
                LMTypeDescriptor descriptor1;
                LMTypeDescriptor descriptor2;
                [[theValue(descriptor1 != descriptor2) should] equal:theValue(false)];
            });
            it(@"Should work on non-empty equal objects", ^{
                LMTypeDescriptor descriptor1;
                descriptor1.objcClass = [NSObject class];
                descriptor1.protocols.insert(@protocol(NSCoding));
                descriptor1.protocols.insert(@protocol(NSCopying));
                LMTypeDescriptor descriptor2;
                descriptor2.objcClass = [NSObject class];
                descriptor2.protocols.insert(@protocol(NSCoding));
                descriptor2.protocols.insert(@protocol(NSCopying));
                [[theValue(descriptor1 != descriptor2) should] equal:theValue(false)];
            });
            it(@"Should work on non-empty non-equal objects", ^{
                LMTypeDescriptor descriptor1;
                descriptor1.objcClass = [NSObject class];
                descriptor1.protocols.insert(@protocol(NSCoding));
                descriptor1.protocols.insert(@protocol(NSCopying));
                LMTypeDescriptor descriptor2;
                descriptor2.objcClass = [NSObject class];
                descriptor2.protocols.insert(@protocol(NSCoding));
                [[theValue(descriptor1 != descriptor2) should] equal:theValue(true)];
            });
        });
SPEC_END
