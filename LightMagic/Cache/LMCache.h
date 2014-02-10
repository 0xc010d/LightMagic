#pragma once
#import <Foundation/Foundation.h>
#import <objc/objc.h>

#include <map>
#include <set>

#import "LMDefinitions.h"

#include "LMBiMap.h"
#include "LMClassComparator.h"
#include "LMInitializerMap.h"
#include "LMInitializerDescriptor.h"

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

    void setInitializer(LMInitializerBlock initializer, LMInitializerDescriptor descriptor);
    void removeInitializer(LMInitializerDescriptor descriptor);
    LMInitializerBlock initializer(LMInitializerDescriptor descriptor);
};
