#include "LMCache.h"

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializerBlock initializer, Class propertyClass, Class containerClass) {
    _initializerMap.set(initializer, propertyClass, containerClass);
    remapInitializerCache(propertyClass);
}

void LMCache::removeInitializer(Class propertyClass, Class containerClass) {
    _initializerMap.erase(propertyClass, containerClass);
    remapInitializerCache(propertyClass);
}

LMInitializerBlock LMCache::initializer(Class propertyClass, Class containerClass) {
    return _initializerMap.find(propertyClass, containerClass);
}

#pragma mark - Private

void LMCache::remapInitializerCache(Class propertyClass) {
    for (auto& containerIterator : getterCache[propertyClass]) {
        Class injectedClass = containerIterator.first;
        Class containerClass = injectedClasses.reversed()[injectedClass];
        for (auto& getter : containerIterator.second) {
            initializerCache[injectedClass][getter] = initializer(propertyClass, containerClass);
        }
    }
}
