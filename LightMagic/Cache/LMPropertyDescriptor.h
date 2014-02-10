#pragma once

#include <set>
#include "LMTypeDescriptor.h"

class LMPropertyDescriptor {
public:
    Class container;
    LMTypeDescriptor type;

    LMPropertyDescriptor(LMTypeDescriptor typeDescriptor = LMTypeDescriptor(), Class containerClass = nil) : type(typeDescriptor) {
        container = containerClass;
    }
};
