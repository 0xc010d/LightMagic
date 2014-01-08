#ifndef __LMCache_H_
#define __LMCache_H_

#include <map>
#include <set>

#import <Foundation/Foundation.h>
#import <objc/objc.h>

#import "LMDefinitions.h"

struct ClassComparator {
    bool operator()(Class a, Class b) const;
};

class LMCache {
private:
    struct ClassInitializersNode {
        LMInitializer initializer;
        std::map<Class, LMInitializer, ClassComparator> containers;
    };

    std::map<Class, ClassInitializersNode *> _initializers;

    ClassInitializersNode *initializersNode(Class propertyClass);
    void removeInitializersNodeIfNeeded(Class propertyClass);
    void remapInitializersCache(Class propertyClass);
public:
    std::map<Class, Class> injectedClasses;
    std::map<Class, Class> containerClasses;

    std::map<id, id> injectedObjects;
    std::map<id, id> containerObjects;

    std::map<Class, std::map<SEL, LMInitializer>> initializersCache; // <injectedClass, <getter, initializer>>
    std::map<Class, std::map<Class, std::set<SEL>>> gettersCache; // <propertyClass, <injectedClass, <getter>>>

    static LMCache & getInstance();

    void setInitializer(LMInitializer initializer, Class propertyClass);
    void setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass);
    void removeInitializer(Class propertyClass);
    void removeInitializer(Class propertyClass, Class containerClass);
    LMInitializer initializer(Class propertyClass);
    LMInitializer initializer(Class propertyClass, Class containerClass);
};

#endif
