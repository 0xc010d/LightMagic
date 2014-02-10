#include "LMCache.h"

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializerBlock initializer, LMInitializerDescriptor descriptor) {
    _initializerMap.set(descriptor, initializer);
    remapInitializerCache(descriptor.type.objcClass);
}

void LMCache::removeInitializer(LMInitializerDescriptor descriptor) {
    _initializerMap.erase(descriptor);
    remapInitializerCache(descriptor.type.objcClass);
}

LMInitializerBlock LMCache::initializer(LMInitializerDescriptor descriptor) {
    return _initializerMap.find(descriptor);
}

#pragma mark - Private

void LMCache::remapInitializerCache(Class propertyClass) {
    //TODO: Implement for protocols
    LMInitializerDescriptor descriptor(propertyClass);
    for (auto& containerIterator : getterCache[propertyClass]) {
        Class injectedClass = containerIterator.first;
        descriptor.container = injectedClasses.reversed()[injectedClass];
        for (auto& getter : containerIterator.second) {
            initializerCache[injectedClass][getter] = initializer(descriptor);
        }
    }
}
