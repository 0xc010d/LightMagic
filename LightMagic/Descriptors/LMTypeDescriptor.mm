#import <objc/runtime.h>
#include <regex>
#include "LMTypeDescriptor.h"

LMTypeDescriptor::LMTypeDescriptor(const char *str) {
    parse(str);
}

bool LMTypeDescriptor::operator ==(const LMTypeDescriptor &other) {
    return objcClass == other.objcClass && protocols == other.protocols;
}

bool LMTypeDescriptor::operator !=(const LMTypeDescriptor &other) {
    return objcClass != other.objcClass && protocols != other.protocols;
}

void LMTypeDescriptor::parse(const char *str) {
    if (strlen(str) > 1) {
        std::string type = std::string(str + 1);
        type.erase(std::remove(type.begin(), type.end(), '"'), type.end());
        size_t leftBracket = type.find('<');
        if (leftBracket != std::string::npos) {
            size_t rightBracket = type.rfind('>') + 1;

            std::regex regex("<(.+?)>");
            std::smatch match;
            std::string protocolString = type.substr(leftBracket, rightBracket - leftBracket);
            while (std::regex_search(protocolString, match, regex)) {
                const char *name = match[1].str().c_str();
                Protocol *protocol = objc_getProtocol(name);
                if (protocol) {
                    protocols.insert(protocol);
                }
                protocolString = match.suffix().str();
            }
            type.erase(leftBracket, rightBracket - leftBracket);
        }
        objcClass = objc_getClass(type.c_str());
    }
    else {
        objcClass = nil;
    }
}

std::string LMTypeDescriptor::str() {
    if (objcClass || protocols.size() > 0) {
        std::string result = std::string("@\"");
        if (objcClass) {
            result += class_getName(objcClass);
        }
        for (Protocol *protocol : protocols) {
            result += "<";
            result += protocol_getName(protocol);
            result += ">";
        }
        result += "\"";
        return result;
    }
    return std::string("@");
}

bool operator <(const LMTypeDescriptor &x, const LMTypeDescriptor &y) {
    return x.objcClass < y.objcClass && x.protocols < y.protocols;
}
