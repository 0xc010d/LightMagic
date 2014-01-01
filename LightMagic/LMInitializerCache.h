#import <map>
#import "LMDefinitions.h"

#ifndef __LMClassCache_H_
#define __LMClassCache_H_

struct ClassCompare {
    bool operator()(Class a, Class b) const {
        return [a isSubclassOfClass:b];
    }
};

struct class_node {
    LMInitializer initializer;
    std::map<Class, LMInitializer, ClassCompare> containers;
};

class LMInitializerCache {
public:
    void setInitializer(Class propertyClass, Class containerClass, LMInitializer initializer);
    void removeInitializer(Class propertyClass, Class containerClass);
    LMInitializer initializer(Class propertyClass, Class containerClass);

private:
    std::map<Class, class_node*> _cache;
};

#endif //__LMClassCache_H_
