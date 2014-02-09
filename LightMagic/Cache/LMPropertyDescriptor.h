#pragma once

#import <set>

class LMPropertyDescriptor {
public:
    Class propertyClass;
    Class containerClass;
    std::set<id> protocols;

    LMPropertyDescriptor(Class _propertyClass = nil, Class _containerClass = nil, std::set<id> _protocols = std::set<id>()) {
        propertyClass = _propertyClass;
        containerClass = _containerClass;
        protocols = _protocols;
    };
};
