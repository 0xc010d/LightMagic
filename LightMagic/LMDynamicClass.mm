#import <objc/runtime.h>
#import <set>
#import "LMDynamicClass.h"
#import "LMTemplateClass.h"
#import "LMProperty.h"

static Class kRootClass;
static const char *kSuffix = "_LMDynamicClass";
static size_t kSuffixLength;

@implementation LMDynamicClass {
    Class _injectedClass;
}

+ (void)initialize {
    kRootClass = [LMTemplateClass class];
    kSuffixLength = strlen(kSuffix);
}

- (instancetype)initWithBaseName:(const char *)baseName {
    self = [super init];

    size_t nameLength = strlen(baseName) + kSuffixLength;
    char name[nameLength + 1];
    sprintf(name, "%s%s", baseName, kSuffix);

    _injectedClass = objc_allocateClassPair(kRootClass, (const char *)name, 0);

    return self;
}

- (Class)injectedClass {
    return _injectedClass;
}

- (void)register {
    objc_registerClassPair(_injectedClass);
}

- (void)addProperty:(LMProperty *)property {
    lm_class_addProperty(_injectedClass, property.clazz, property.getter);
}

@end
