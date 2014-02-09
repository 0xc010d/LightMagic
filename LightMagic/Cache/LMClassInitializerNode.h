#pragma once

#import <objc/runtime.h>

#include <map>

#import "LMDefinitions.h"

#include "LMClassComparator.h"

class LMClassInitializerNode {
private:
    LMInitializerBlock _initializer;
    std::map<Class, LMInitializerBlock, LMClassComparator> _containerMap;
public:
    const LMInitializerBlock find(Class& container);
    void set(LMInitializerBlock value, Class& container);
    void erase(Class& container);
    LMClassInitializerNode() { _initializer = nil; };
};
