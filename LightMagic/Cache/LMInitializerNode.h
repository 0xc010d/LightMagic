#pragma once

#import <set>
#include "LMClassInitializerNode.h"

class LMInitializerNode : public LMClassInitializerNode {
private:
    std::map<std::set<id>, LMClassInitializerNode> _protocolMap;

    LMClassInitializerNode * initializerNode(const std::set<id>& protocols)  {
        if (protocols.size() > 0) {
            auto node = _protocolMap.find(protocols);
            if (node != _protocolMap.end()) {
                return &node->second;
            }
        }
        return NULL;
    }

public:
    const LMInitializerBlock find(Class& container, const std::set<id>& protocols = std::set<id>())  {
        LMClassInitializerNode *node = initializerNode(protocols);
        if (node != NULL) return node->find(container);
        else return LMClassInitializerNode::find(container);
    }

    void set(LMInitializerBlock value, Class& container, const std::set<id>& protocols = std::set<id>())  {
        LMClassInitializerNode *node = initializerNode(protocols);
        if (node != NULL) node->set(value, container);
        else LMClassInitializerNode::set(value, container);
    }

    void erase(Class& container, const std::set<id>& protocols = std::set<id>())  {
        LMClassInitializerNode *node = initializerNode(protocols);
        if (node != NULL) node->erase(container);
        else return LMClassInitializerNode::erase(container);
    }
};
