#pragma once

#include <set>
#include <string>

class LMTypeDescriptor {
public:
    Class objcClass;
    std::set<id> protocols;

    LMTypeDescriptor(const char *str = "");
    bool operator== (const LMTypeDescriptor& other);
    bool operator!= (const LMTypeDescriptor& other);
    bool operator< (const LMTypeDescriptor& other);

    void parse(const char *str);
    std::string str();
};
