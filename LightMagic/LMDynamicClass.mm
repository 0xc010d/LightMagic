#import <objc/runtime.h>
#import "LMDynamicClass.h"
#import "LMTemplateClass.h"

static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

@implementation LMDynamicClass {
    Class _clazz;
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

    _clazz = objc_allocateClassPair(kRootClass, (const char *)name, 0);

    return self;
}

- (Class)clazz {
    return _clazz;
}

- (void)register {
    objc_registerClassPair(_clazz);
}

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector {
    const char *name = sel_getName(selector);
    uint attributesCount;
    objc_property_attribute_t *attributes = lm_propertyAttributesForClass(clazz, &attributesCount);
    class_addProperty(_clazz, name, attributes, attributesCount);
    class_addMethod(_clazz, selector, (IMP)lm_dynamicGetter, "@@:");
}

@end
