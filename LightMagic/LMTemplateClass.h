#import <Foundation/Foundation.h>
#import <map>

@interface LMTemplateClass : NSObject {
@public
    std::map<SEL, id> values;
}

@end

extern id lm_dynamicGetter(LMTemplateClass *self, SEL _cmd);
