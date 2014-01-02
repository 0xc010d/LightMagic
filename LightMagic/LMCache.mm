#import "LMCache.h"

bool ClassCompare::operator ()(Class a, Class b) const {
    return [a isSubclassOfClass:b];
}

LMCache& LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (!node) {
        node = new class_initializers_node;
        _initializers[propertyClass] = node;
    }
    if (!containerClass) {
        (*node).initializer = [initializer copy];
    }
    else {
        //TODO: implement container class case
    }
}

void LMCache::removeInitializer(Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        if (!containerClass) {
            node->initializer = nil;
        }
        else {
            //TODO: implement container class case
        }
        if (node->containers.size() == 0 && !node->initializer) {
            _initializers.erase(propertyClass);
            delete node;
        }
    }
}

BOOL LMCache::hasContainerInitializer(Class propertyClass, BOOL *hasDefaultInitializer) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        if (node->containers.size() != 0) {
            return YES;
        }
        *hasDefaultInitializer = node->initializer != nil;
    }
    else {
        *hasDefaultInitializer = NO;
    }
    return NO;
}

LMInitializer LMCache::defaultInitializer(Class propertyClass) {
    return _initializers[propertyClass]->initializer;
}

LMInitializer LMCache::initializer(Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        if (!containerClass) {
            return node->initializer;
        }
        else {
            //TODO: implement container class case
        }
    }
    return nil;
}
