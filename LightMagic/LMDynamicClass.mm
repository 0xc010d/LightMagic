#import <objc/runtime.h>
#import "LMDynamicClass.h"
#import "LMTemplateClass.h"

static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

@implementation LMDynamicClass {
    Class _dynamicClass;
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

    _dynamicClass = objc_allocateClassPair(kRootClass, (const char *)name, 0);

    return self;
}

- (Class)clazz {
    return _dynamicClass;
}

- (void)register {
    objc_registerClassPair(_dynamicClass);
}

- (void)addPropertyWithClass:(Class)clazz getter:(SEL)selector {
    lm_class_addProperty(_dynamicClass, clazz, selector);
}

@end
