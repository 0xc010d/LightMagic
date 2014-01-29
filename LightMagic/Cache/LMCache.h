#pragma once
#include <map>
#include <set>

#include "LMBiMap.h"

#import <Foundation/Foundation.h>
#import <objc/objc.h>

#import "LMDefinitions.h"

typedef std::map<const Class, std::map<const SEL, LMInitializer>> LMInitializerCache;
typedef std::map<const Class, std::map<const Class, std::set<const SEL>>> LMGetterCache;

class ClassComparator {
public:
    bool operator() (Class a, Class b) const;
};

class LMCache {
private:
    struct ClassInitializersNode {
        LMInitializer initializer;
        std::map<const Class, LMInitializer, ClassComparator> containers;
    };

    std::map<const Class, ClassInitializersNode*> _initializers;

    void remapInitializersCache(Class propertyClass);
public:
    static LMCache& getInstance();

    LMBiMap<Class, Class> injectedClasses;
    LMBiMap<id, id> injectedObjects;

    LMInitializerCache initializerCache; // <injectedClass, <getter, initializer>>
    LMGetterCache getterCache; // <propertyClass, <injectedClass, <getter>>>

    void setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass = nil);
    void removeInitializer(Class propertyClass, Class containerClass = nil);
    LMInitializer initializer(Class propertyClass, Class containerClass = nil);
};
