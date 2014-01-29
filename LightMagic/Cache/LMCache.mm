#include "LMCache.h"

bool ClassComparator::operator()(Class a, Class b) const {
    if (a == b) {
        return false;
    }
    else if ([a isSubclassOfClass:b]) {
        return true;
    }
    else if ([b isSubclassOfClass:a]) {
        return false;
    }
    else {
        return a < b;
    }
}

LMCache &LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass) {
    ClassInitializersNode *node = initializersNode(propertyClass);
    if (!containerClass && node->initializer != initializer) {
        node->initializer = [initializer copy];
    }
    else if (node->containers[containerClass] != initializer) {
        node->containers[containerClass] = [initializer copy];
    }
    remapInitializersCache(propertyClass);
}

void LMCache::removeInitializer(Class propertyClass, Class containerClass) {
    ClassInitializersNode *node = _initializers[propertyClass];
    if (node) {
        if (!containerClass) {
            node->initializer = nil;
        }
        else {
            node->containers.erase(containerClass);
        }
        removeInitializersNodeIfNeeded(propertyClass);
    }
    remapInitializersCache(propertyClass);
}

LMInitializer LMCache::initializer(Class propertyClass, Class containerClass) {
    ClassInitializersNode *node = _initializers[propertyClass];
    if (node) {
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
    return nil;
}

#pragma mark - Private

LMCache::ClassInitializersNode *LMCache::initializersNode(Class propertyClass) {
    ClassInitializersNode *node = _initializers[propertyClass];
    if (!node) {
        node = new ClassInitializersNode;
        _initializers[propertyClass] = node;
    }
    return node;
}

void LMCache::removeInitializersNodeIfNeeded(Class propertyClass) {
    ClassInitializersNode *node = _initializers[propertyClass];
    if (node && node->containers.size() == 0 && !node->initializer) {
        _initializers.erase(propertyClass);
        delete node;
    }
}

void LMCache::remapInitializersCache(Class propertyClass) {
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
