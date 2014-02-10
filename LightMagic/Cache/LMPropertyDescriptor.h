#pragma once

#include <set>

class LMPropertyDescriptor {
public:
    Class propertyClass;
    Class container;
    std::set<id> protocols;

    LMPropertyDescriptor(Class _propertyClass = nil, Class _containerClass = nil, std::set<id> _protocols = std::set<id>()) {
        propertyClass = _propertyClass;
        container = _containerClass;
        protocols = _protocols;
    };
};
