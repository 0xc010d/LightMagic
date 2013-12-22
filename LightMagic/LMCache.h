#import <Foundation/Foundation.h>
#import <map>

#import "LMDefinitions.h"

#ifndef __LMCache_H_
#define __LMCache_H_

class LMCache {
public:
    std::map<Class, Class> dynamicClasses;
    std::map<id, id> dynamicObjects;

    static LMCache& getInstance();

    void setInitializer(Class, LMInitializer);
    void removeInitializer(Class);
    LMInitializer initializer(Class);

private:
    std::map<Class, LMInitializer> initializers;
};

#endif
