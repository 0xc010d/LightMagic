#pragma once

#include <set>
#include "LMTypeDescriptor.h"

class LMInitializerDescriptor {
public:
    Class container;
    LMTypeDescriptor type;

    LMInitializerDescriptor(LMTypeDescriptor typeDescriptor = LMTypeDescriptor(), Class containerClass = nil) : type(typeDescriptor) {
        container = containerClass;
    }
};
