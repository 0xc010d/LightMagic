#pragma once

#import <set>
#include "LMClassInitializerNode.h"

class LMInitializerNode : public LMClassInitializerNode {
private:
    std::map<std::set<id>, LMClassInitializerNode> _protocolMap;

    LMClassInitializerNode * initializerNode(const std::set<id>& protocols);
public:
    const LMInitializerBlock find(Class& container, const std::set<id>& protocols = std::set<id>());

    void set(LMInitializerBlock value, Class& container, const std::set<id>& protocols = std::set<id>());

    void erase(Class& container, const std::set<id>& protocols = std::set<id>());
};
