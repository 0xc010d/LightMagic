#pragma once
#include <map>
#include <set>

#include "LMBiMap.h"

#import <Foundation/Foundation.h>
#import <objc/objc.h>

#import "LMDefinitions.h"

typedef std::map<Class, std::map<SEL, LMInitializer>> LMInitializerCache;
typedef std::map<Class, std::map<Class, std::set<SEL>>> LMGetterCache;

struct ClassComparator {
    bool operator() (Class a, Class b) const;
};

class LMCache {
private:
    struct ClassInitializersNode {
        LMInitializer initializer;
        std::map<Class, LMInitializer, ClassComparator> containers;
    };

    std::map<Class, ClassInitializersNode*> _initializers;

    ClassInitializersNode *initializersNode(Class propertyClass);
    void removeInitializersNodeIfNeeded(Class propertyClass);
    void remapInitializersCache(Class propertyClass);
public:
    static LMCache& getInstance();

    LMBiMap<Class, Class> injectedClasses;
    LMBiMap<id, id> injectedObjects;

    LMInitializerCache initializerCache; // <injectedClass, <getter, initializer>>
    LMGetterCache getterCache; // <propertyClass, <injectedClass, <getter>>>

    void setInitializer(LMInitializer initializer, Class propertyClass);
    void setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass);
    void removeInitializer(Class propertyClass);
    void removeInitializer(Class propertyClass, Class containerClass);
    LMInitializer initializer(Class propertyClass);
    LMInitializer initializer(Class propertyClass, Class containerClass);
};
