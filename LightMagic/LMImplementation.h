#import <Foundation/Foundation.h>

#define LMSelectorAllocWithZone @selector(allocWithZone_:)
#define LMSelectorDealloc @selector(dealloc_)

@interface NSObject (LMSelector)

+ (instancetype)allocWithZone_:(NSZone *)zone;
- (void)dealloc_;

@end

extern IMP imp(SEL selector);
extern IMP getter(BOOL forwarding);
