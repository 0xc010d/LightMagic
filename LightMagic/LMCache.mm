#import "LMCache.h"

LMCache& LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(Class clazz, LMInitializer initializer) {
    classInitializers->setInitializer(clazz, nil, initializer);
}

void LMCache::removeInitializer(Class clazz) {
    classInitializers->removeInitializer(clazz, nil);
}

LMInitializer LMCache::initializer(Class clazz) {
    return classInitializers->initializer(clazz, nil);
}

LMCache::~LMCache() {
    delete classInitializers;
}
