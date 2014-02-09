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
    void set(LMInitializerBlock initializer, Class& container, const std::set<id>& protocols = std::set<id>())  {
        if (protocols.size() > 0) {
            LMClassInitializerNode *node = initializerNode(protocols);
            if (node != NULL) node->set(initializer, container);
        }
        else LMClassInitializerNode::set(initializer, container);
    }

    const LMInitializerBlock find(Class& container, const std::set<id>& protocols = std::set<id>())  {
        if (protocols.size() > 0) {
            LMClassInitializerNode *node = initializerNode(protocols);
            if (node != NULL) return node->find(container);
            else return nil;
        }
        else return LMClassInitializerNode::find(container);
    }

    void erase(Class& container, const std::set<id>& protocols = std::set<id>())  {
        if (protocols.size() > 0) {
            LMClassInitializerNode *node = initializerNode(protocols);
            if (node != NULL) node->erase(container);
        }
        else LMClassInitializerNode::erase(container);
    }
};
