#pragma once

class LMClassComparator {
public:
    bool operator() (Class a, Class b) const {
        if (a == b) return false;
        else if ([a isSubclassOfClass:b]) return true;
        else if ([b isSubclassOfClass:a]) return false;
        else return a < b;
    }
};
