#pragma once

#import <map>
#include "LMInitializerNode.h"

class LMInitializerMap {
private:
    std::map<const Class, LMInitializerNode> _internalMap;
public:
    const LMInitializerBlock find(Class& objcClass, Class container) {
        return _internalMap[objcClass].find(container);
    }
    void set(LMInitializerBlock initializer, Class& objcClass, Class container) {
        _internalMap[objcClass].set(initializer, container);
    }
    void erase(Class& objcClass, Class container) {
        _internalMap[objcClass].erase(container);
    }
};
