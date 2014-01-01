#include "LMInitializerCache.h"

void LMInitializerCache::setInitializer(Class propertyClass, Class containerClass, LMInitializer initializer) {
    class_node *nodePtr = _cache[propertyClass];
    if (!nodePtr) {
        nodePtr = new class_node;
        _cache[propertyClass] = nodePtr;
    }
    if (!containerClass) {
        (*nodePtr).initializer = [initializer copy];
    }
    else {
        //TODO: implement container class case
    }
}

void LMInitializerCache::removeInitializer(Class propertyClass, Class containerClass) {
    class_node *nodePtr = _cache[propertyClass];
    if (nodePtr) {
        class_node node = *nodePtr;
        if (!containerClass) {
            node.initializer = nil;
        }
        else {
            //TODO: implement container class case
        }
        if (node.containers.size() == 0 && !node.initializer) {
            delete nodePtr;
            _cache.erase(propertyClass);
        }
    }
}

LMInitializer LMInitializerCache::initializer(Class propertyClass, Class containerClass) {
    LMInitializer initializer = nil;
    class_node *nodePtr = _cache[propertyClass];
    if (nodePtr) {
        class_node node = *nodePtr;
        if (!containerClass) {
            initializer = node.initializer;
        }
        else {
            //TODO: implement container class case
        }
    }
    return initializer;
}
