#import <objc/runtime.h>
#import "LMDynamicClass.h"
#import "LMTemplateClass.h"

static Class kRootClass;
static const char *kSuffix = "_LMDynamicClass";
static size_t kSuffixLength;

@implementation LMDynamicClass {
    Class _containerClass;
    Class _injectedClass;
}

+ (void)initialize {
    kRootClass = [LMTemplateClass class];
    kSuffixLength = strlen(kSuffix);
}

- (instancetype)initWithContainerClass:(Class)containerClass {
    self = [super init];

    const char *baseName = class_getName(containerClass);
    size_t nameLength = strlen(baseName) + kSuffixLength;
    char name[nameLength + 1];
    sprintf(name, "%s%s", baseName, kSuffix);
    _injectedClass = objc_allocateClassPair(kRootClass, (const char *)name, 0);

    _containerClass = containerClass;

    return self;
}

- (Class)injectedClass {
    return _injectedClass;
}

- (void)addPropertyWithDescriptor:(LMInitializerDescriptor)descriptor getter:(SEL)getter {
    descriptor.container = _containerClass;
    lm_class_addProperty(_injectedClass, getter, descriptor);
}

- (void)register {
    objc_registerClassPair(_injectedClass);
}

@end
