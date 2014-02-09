#pragma once

#include <map>

#include "LMInitializerNode.h"
#include "LMPropertyDescriptor.h"

class LMInitializerMap {
private:
    std::map<const Class, LMInitializerNode> _internalMap;
public:
    void set(LMPropertyDescriptor &descriptor, LMInitializerBlock initializer) {
        Class propertyClass = descriptor.propertyClass;
        Class containerClass = descriptor.containerClass;
        std::set<id> protocols = descriptor.protocols;
        _internalMap[propertyClass].set(initializer, containerClass, protocols);
    }
    const LMInitializerBlock find(LMPropertyDescriptor& descriptor) {
        Class propertyClass = descriptor.propertyClass;
        Class containerClass = descriptor.containerClass;
        std::set<id> protocols = descriptor.protocols;
        return _internalMap[propertyClass].find(containerClass, protocols);
    }
    void erase(LMPropertyDescriptor& descriptor) {
        Class propertyClass = descriptor.propertyClass;
        Class containerClass = descriptor.containerClass;
        std::set<id> protocols = descriptor.protocols;
        _internalMap[propertyClass].erase(containerClass, protocols);
    }
};
