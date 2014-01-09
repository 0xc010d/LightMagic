#ifndef __LMClassCache_H_
#define __LMClassCache_H_

#import <map>

template <class Key, class Value>
class LMBiMap {
protected:
    std::map<Key, Value> *_map;
    LMBiMap<Value, Key> *_reversed;
    LMBiMap(LMBiMap<Key, Value> *natural, LMBiMap<Value, Key> *reversed) {
        _map = natural->_map;
        _reversed = reversed;
    };

public:
    LMBiMap() {
        *_map = std::map<Key, Value>();
        *_reversed = LMBiMap<Value, Key>();
    };
    ~LMBiMap() {
        if (_map != NULL) {
            _reversed->_map = NULL;
            delete _reversed;
            delete _map;
        }
    }
    Value& operator[] (const Key key) {
        return (*_map)[key];
    };
    void set(Key key, Value value) {
        _map[key] = value;
        _reversed->_map[value] = key;
    };
    LMBiMap<Value, Key> reversed() {
        return LMBiMap<Value, Key>();
    };
};

class LMClassCache : public LMBiMap<Class, Class> {
};


#endif //__LMClassCache_H_
