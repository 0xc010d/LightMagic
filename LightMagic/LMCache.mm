#import "LMCache.h"

bool ClassCompare::operator()(Class a, Class b) const {
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

LMCache& LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(LMInitializer initializer, Class propertyClass) {
    _initializersNode(propertyClass)->initializer = [initializer copy];
}

void LMCache::setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializersNode(propertyClass);
    if (!containerClass) {
        node->initializer = [initializer copy];
    }
    else {
        node->containers[containerClass] = [initializer copy];
    }
}

void LMCache::removeInitializer(Class propertyClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        node->initializer = nil;
        _removeInitializersNodeIfNeeded(propertyClass);
    }
}

void LMCache::removeInitializer(Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        if (!containerClass) {
            node->initializer = nil;
        }
        else {
            node->containers.erase(containerClass);
        }
        _removeInitializersNodeIfNeeded(propertyClass);
    }
}

LMInitializer LMCache::initializer(Class propertyClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        return node->initializer;
    }
    return nil;
}

LMInitializer LMCache::initializer(Class propertyClass, Class containerClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        if (!containerClass) {
            return node->initializer;
        }
        LMInitializer initializer = node->initializer;
        std::map<Class, LMInitializer>::iterator iterator = node->containers.begin();
        std::map<Class, LMInitializer>::iterator end = node->containers.end();
        while (iterator != end) {
            if ([containerClass isSubclassOfClass:iterator->first]) {
                initializer = iterator->second;
                break;
            }
            iterator ++;
        }
        return initializer;
    }
    return nil;
}

BOOL LMCache::hasContainerInitializers(Class propertyClass, BOOL *hasDefaultInitializer) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node) {
        *hasDefaultInitializer = node->initializer != nil;
        if (node->containers.size() != 0) {
            return YES;
        }
    }
    else {
        *hasDefaultInitializer = NO;
    }
    return NO;
}

#pragma mark - Private

class_initializers_node *LMCache::_initializersNode(Class propertyClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (!node) {
        node = new class_initializers_node;
        _initializers[propertyClass] = node;
    }
    return node;
}

void LMCache::_removeInitializersNodeIfNeeded(Class propertyClass) {
    class_initializers_node *node = _initializers[propertyClass];
    if (node && node->containers.size() == 0 && !node->initializer) {
        _initializers.erase(propertyClass);
        delete node;
    }
}
