#pragma once
#include <map>
#include <set>

#include "LMBiMap.h"

#import <Foundation/Foundation.h>
#import <objc/objc.h>

#import "LMDefinitions.h"
#import "LMClassComparator.h"
#import "LMInitializerMap.h"
#import "LMPropertyDescriptor.h"

typedef std::map<const Class, std::map<const SEL, LMInitializerBlock>> LMInitializerCache;
typedef std::map<const Class, std::map<const Class, std::set<const SEL>>> LMGetterCache;

class LMCache {
private:
    LMInitializerMap _initializerMap;
    void remapInitializerCache(Class propertyClass);
public:
    static LMCache& getInstance();

    LMBiMap<Class, Class> injectedClasses;
    LMBiMap<id, id> injectedObjects;

    LMInitializerCache initializerCache; // <injectedClass, <getter, initializer>>
    LMGetterCache getterCache; // <propertyClass, <injectedClass, <getter>>>

    void setInitializer(LMInitializerBlock initializer, LMPropertyDescriptor descriptor);
    void removeInitializer(LMPropertyDescriptor descriptor);
    LMInitializerBlock initializer(LMPropertyDescriptor descriptor);
};
