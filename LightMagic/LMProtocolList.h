#import <Foundation/Foundation.h>

typedef struct LMProtocolList {
    uint count;
    Protocol  __unsafe_unretained**protocols;
} LMProtocolList;
