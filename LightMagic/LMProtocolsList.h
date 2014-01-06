#import <Foundation/Foundation.h>

typedef struct LMProtocolsList {
    uint count;
    Protocol  __unsafe_unretained**protocols;
} LMProtocolsList;
