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
    bool operator() (Class a, Class b) const {
        if (a == b) return false;
        else if ([a isSubclassOfClass:b]) return true;
        else if ([b isSubclassOfClass:a]) return false;
        else return a < b;
    }
};

class LMCache {
private:
    class InitializerNode {
    public:
        LMInitializer initializer;
        std::map<const Class, LMInitializer, ClassComparator> containers;
        InitializerNode() { initializer = nil; };
    };

    std::map<const Class, InitializerNode *> _initializers;

    void remapInitializerCache(Class propertyClass);
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
