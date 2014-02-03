#include "LMCache.h"

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass) {
    InitializerNode *node = &_initializers[propertyClass];
    if (!containerClass && node->initializer != initializer) {
        Block_release(node->initializer);
        node->initializer = Block_copy(initializer);
    }
    else if (node->containers[containerClass] != initializer) {
        Block_release(node->containers[containerClass]);
        node->containers[containerClass] = Block_copy(initializer);
    }
    remapInitializerCache(propertyClass);
}

void LMCache::removeInitializer(Class propertyClass, Class containerClass) {
    InitializerNode *node = &_initializers[propertyClass];
    if (!containerClass) {
        Block_release(node->initializer);
        node->initializer = nil;
    }
    else {
        Block_release(node->containers[containerClass]);
        node->containers.erase(containerClass);
    }
    if (node && node->containers.size() == 0 && !node->initializer) {
        _initializers.erase(propertyClass);
    }
    remapInitializerCache(propertyClass);
}

LMInitializer LMCache::initializer(Class propertyClass, Class containerClass) {
    InitializerNode *node = &_initializers[propertyClass];
    if (!containerClass) {
        return node->initializer;
    }
    auto iterator = node->containers.begin();
    auto end = node->containers.end();
    while (iterator != end) {
        if ([containerClass isSubclassOfClass:iterator->first]) {
            return iterator->second;
        }
        iterator ++;
    }
    return node->initializer;
}

#pragma mark - Private

void LMCache::remapInitializerCache(Class propertyClass) {
    auto containersIterator = getterCache[propertyClass].begin();
    auto containersIteratorEnd = getterCache[propertyClass].end();
    while (containersIterator != containersIteratorEnd) {
        Class injectedClass = containersIterator->first;
        Class containerClass = injectedClasses.reversed()[injectedClass];
        auto gettersIterator = containersIterator->second.begin();
        auto gettersIteratorEnd = containersIterator->second.end();
        while (gettersIterator != gettersIteratorEnd) {
            SEL getter = *gettersIterator;
            initializerCache[injectedClass][getter] = initializer(propertyClass, containerClass);
            gettersIterator ++;
        }
        containersIterator ++;
    }
}
