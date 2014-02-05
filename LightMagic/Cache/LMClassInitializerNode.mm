#import "LMClassInitializerNode.h"

const LMInitializerBlock LMClassInitializerNode::find(Class& container) {
    if (container) {
        for (auto iterator : _containerMap) {
            if ([container isSubclassOfClass:iterator.first]) {
                return iterator.second;
            }
        }
    }
    return _initializer;
}

void LMClassInitializerNode::set(LMInitializerBlock value, Class& container) {
    if (container) {
#if __has_feature(objc_arc)
        _containerMap[container] = [value copy];
#else
            auto item = _containerMap.find(container);
            if (item != _containerMap.end()) {
                Block_release(item->second);
            }
            _containerMap[container] = Block_copy(value);
#endif
    }
    else {
#if __has_feature(objc_arc)
        _initializer = [value copy];
#else
            Block_release(_initializer);
            _initializer = Block_copy(value);
#endif
    }
}

void LMClassInitializerNode::erase(Class& container) {
    if (container) {
#if __has_feature(objc_arc)
        _containerMap.erase(container);
#else
            auto item = _containerMap.find(container);
            if (item != _containerMap.end()) {
                Block_release(item->second);
                _containerMap.erase(item);
            }
#endif
    }
    else if (_initializer) {
#if !__has_feature(objc_arc)
            Block_release(_initializer);
#endif
        _initializer = nil;
    }
}