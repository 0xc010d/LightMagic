#include "LMCache.h"

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializerBlock initializer, LMPropertyDescriptor descriptor) {
    _initializerMap.set(descriptor, initializer);
    remapInitializerCache(descriptor.propertyClass);
}

void LMCache::removeInitializer(LMPropertyDescriptor descriptor) {
    _initializerMap.erase(descriptor);
    remapInitializerCache(descriptor.propertyClass);
}

LMInitializerBlock LMCache::initializer(LMPropertyDescriptor descriptor) {
    return _initializerMap.find(descriptor);
}

#pragma mark - Private

void LMCache::remapInitializerCache(Class propertyClass) {
    //TODO: Implement for protocols
    LMPropertyDescriptor descriptor(propertyClass);
    for (auto& containerIterator : getterCache[propertyClass]) {
        Class injectedClass = containerIterator.first;
        descriptor.container = injectedClasses.reversed()[injectedClass];
        for (auto& getter : containerIterator.second) {
            initializerCache[injectedClass][getter] = initializer(descriptor);
        }
    }
}
