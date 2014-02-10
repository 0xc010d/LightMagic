#pragma once

#include <set>
#include <string>

class LMTypeDescriptor {
public:
    Class objcClass;
    std::set<id> protocols;

    LMTypeDescriptor(const char *str = "");
    LMTypeDescriptor(Class _objcClass, std::set<id> _protocols = std::set<id>()) : protocols(_protocols) {
        objcClass = _objcClass;
    };

    bool operator== (const LMTypeDescriptor& other);
    bool operator!= (const LMTypeDescriptor& other);
    bool operator< (const LMTypeDescriptor& other);

    void parse(const char *str);
    std::string str();
};
