#include "LMCache.h"

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializerBlock initializer, LMInitializerDescriptor descriptor) {
    _initializerMap.set(descriptor, initializer);
    remapInitializerCache(descriptor);
}

void LMCache::removeInitializer(LMInitializerDescriptor descriptor) {
    _initializerMap.erase(descriptor);
    remapInitializerCache(descriptor);
}

LMInitializerBlock LMCache::initializer(LMInitializerDescriptor descriptor) {
    return _initializerMap.find(descriptor);
}

#pragma mark - Private

void LMCache::remapInitializerCache(LMInitializerDescriptor descriptor) {
    //TODO: simplify caches
    const auto& container = getterCache.find(descriptor.type);
    if (container != getterCache.end()) {
        for (auto& containerIterator : container->second) {
            Class injectedClass = containerIterator.first;
            descriptor.container = injectedClasses.reversed()[injectedClass];
            for (auto& getter : containerIterator.second) {
                initializerCache[injectedClass][getter] = initializer(descriptor);
            }
        }
    }
}
