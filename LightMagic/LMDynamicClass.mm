#import <objc/runtime.h>
#import "LMDynamicClass.h"
#import "LMTemplateClass.h"

static Class kRootClass;
static const char *kSuffix = "_LMInjectedClass";
static size_t kSuffixLength;

@implementation LMDynamicClass {
#if LM_FORCED_CACHE
    Class _containerClass;
#endif
    Class _dynamicClass;
}

+ (void)initialize {
    kRootClass = [LMTemplateClass class];
    kSuffixLength = strlen(kSuffix);
}

#if LM_FORCED_CACHE
- (instancetype)initWithContainerClass:(Class)containerClass {
    const char *baseName = class_getName(containerClass);

    self = [self initWithBaseName:baseName];

    _containerClass = containerClass;

    return self;
}
#endif

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
#if LM_FORCED_CACHE
    lm_class_addProperty(_containerClass, _dynamicClass, clazz, selector);
#else
    lm_class_addProperty(_dynamicClass, clazz, selector);
#endif
}

@end
