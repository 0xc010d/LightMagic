#import "LMInitializerNode.h"

LMClassInitializerNode *LMInitializerNode::initializerNode(const std::set<id>& protocols) {
    if (protocols.size() > 0) {
        auto node = _protocolMap.find(protocols);
        if (node != _protocolMap.end()) {
            return &node->second;
        }
    }
    return NULL;
}

const LMInitializerBlock LMInitializerNode::find(Class& container, const std::set<id>& protocols) {
    LMClassInitializerNode *node = initializerNode(protocols);
    if (node != NULL) return node->find(container);
    else return LMClassInitializerNode::find(container);
}

void LMInitializerNode::set(LMInitializerBlock value, Class& container, const std::set<id>& protocols) {
    LMClassInitializerNode *node = initializerNode(protocols);
    if (node != NULL) node->set(value, container);
    else LMClassInitializerNode::set(value, container);
}

void LMInitializerNode::erase(Class& container, const std::set<id>& protocols) {
    LMClassInitializerNode *node = initializerNode(protocols);
    if (node != NULL) node->erase(container);
    else return LMClassInitializerNode::erase(container);
}