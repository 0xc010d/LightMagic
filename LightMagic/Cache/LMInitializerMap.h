#pragma once

#include <map>

#include "LMInitializerNode.h"
#include "LMInitializerDescriptor.h"

class LMInitializerMap {
private:
    std::map<Class, LMInitializerNode> _internalMap;
public:
    void set(LMInitializerDescriptor &descriptor, LMInitializerBlock initializer) {
        Class propertyClass = descriptor.type.objcClass;
        Class containerClass = descriptor.container;
        std::set<id> protocols = descriptor.type.protocols;
        _internalMap[propertyClass].set(initializer, containerClass, protocols);
    }
    const LMInitializerBlock find(LMInitializerDescriptor & descriptor) {
        Class propertyClass = descriptor.type.objcClass;
        Class containerClass = descriptor.container;
        std::set<id> protocols = descriptor.type.protocols;
        return _internalMap[propertyClass].find(containerClass, protocols);
    }
    void erase(LMInitializerDescriptor & descriptor) {
        Class propertyClass = descriptor.type.objcClass;
        Class containerClass = descriptor.container;
        std::set<id> protocols = descriptor.type.protocols;
        _internalMap[propertyClass].erase(containerClass, protocols);
    }
};
