#ifndef __LMBiMap_H_
#define __LMBiMap_H_

#include <map>

template <typename Key, typename Value>
class LMBiMap {
    friend class LMBiMap<Value, Key>;
    std::map<Key, Value> _map;
    LMBiMap<Value, Key> *_reversed;
    LMBiMap(LMBiMap<Value, Key> *reversed) {
        _reversed = reversed;
    };
public:
    LMBiMap() {
        _reversed = new LMBiMap<Value, Key>(this);
    };
    Value& operator[] (const Key& key) {
        return _map[key];
    };
    void set(Key key, Value value) {
        _reversed->_map.erase(_map[key]);
        _map[key] = value;
        _reversed->_map[value] = key;
    };
    void erase(Key key) {
        _reversed->_map.erase(_map[key]);
        _map.erase(key);
    }
    LMBiMap<Value, Key> reversed() {
        return *_reversed;
    };
};

#endif //__LMBiMap_H_
