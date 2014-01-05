#import <Foundation/Foundation.h>

@class NonExistentClass;
@protocol NonExistentProtocol;

@interface LMPropertiesParserTest : NSObject

@property id dynamicProperty;
@property id synthesizedProperty;

@property id idProperty;
@property NSObject *classProperty;
@property NonExistentClass *nonExistentClassProperty;
@property id<NonExistentProtocol, NSObject> nonExistentProtocolProperty;

@property id<NSObject> idProtocolProperty;
@property id<UITableViewDelegate, UITableViewDataSource> idProtocolsProperty;
@property NSObject<NSCopying> *classProtocolProperty;
@property NSObject<UITableViewDelegate, UITableViewDataSource> *classProtocolsProperty;

@property (getter=customGetter) id customGetterProperty;
@property id defaultGetterProperty;

@end