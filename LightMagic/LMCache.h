#import <Foundation/Foundation.h>
#import <map>
#import <set>

#import "LMDefinitions.h"

#ifndef __LMCache_H_
#define __LMCache_H_

struct ClassCompare {
    bool operator()(Class a, Class b) const;
};

struct class_initializers_node {
    LMInitializer initializer;
    std::map<Class, LMInitializer, ClassCompare> containers;
};

class LMCache {
public:
    std::map<Class, Class> injectedClasses;
    std::map<Class, Class> containerClasses;

    std::map<id, id> injectedObjects;
    std::map<id, id> containerObjects;

    std::map<Class, std::map<SEL, LMInitializer>> initializersCache; // <injectedClass, <getter, initializer>>
    std::map<Class, std::map<Class, std::set<SEL>>> gettersCache; // <propertyClass, <injectedClass, <getter>>>

    static LMCache& getInstance();

    void setInitializer(LMInitializer initializer, Class propertyClass);
    void setInitializer(LMInitializer initializer, Class propertyClass, Class containerClass);
    void removeInitializer(Class propertyClass);
    void removeInitializer(Class propertyClass, Class containerClass);
    LMInitializer initializer(Class propertyClass);
    LMInitializer initializer(Class propertyClass, Class containerClass);

private:
    std::map<Class, class_initializers_node *> _initializers;
    class_initializers_node *_initializersNode(Class propertyClass);
    void _removeInitializersNodeIfNeeded(Class propertyClass);
    void _remapInitializersCache(Class propertyClass);
};

#endif
