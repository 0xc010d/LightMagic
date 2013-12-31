#import "LMCache.h"

LMCache& LMCache::getInstance() {
    static LMCache instance;
    return instance;
}

void LMCache::setInitializer(Class clazz, LMInitializer initializer) {
    initializers[clazz] = [initializer copy];
}

void LMCache::removeInitializer(Class clazz) {
    initializers.erase(clazz);
}

LMInitializer LMCache::initializer(Class clazz) {
    return initializers[clazz];
}
