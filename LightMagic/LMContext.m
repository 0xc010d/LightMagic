#import "LMContext.h"

@implementation LMContext {
    NSMapTable *_initializers;
    dispatch_queue_t _queue;
}

+ (instancetype)defaultContext {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setInitializer:(id (^)(void))initializer forClass:(Class)clazz {
    dispatch_barrier_async(_queue, ^{
        [_initializers setObject:initializer forKey:clazz];
    });
}

- (id (^)(void))initializerForClass:(Class)clazz {
    __block id (^initializer)(void);
    dispatch_sync(_queue, ^{
        initializer = [_initializers objectForKey:clazz];
        if (!initializer) {
            initializer = [self defaultInitializerForClass:clazz];
            [self setInitializer:initializer forClass:clazz];
        }
    });
    return initializer;
}

#pragma mark - Private

- (instancetype)init {
    self = [super init];
    _initializers = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory capacity:0];

    static const char * kBarrierQueueName = "com.0xc010d.barrier";
    _queue = dispatch_queue_create(kBarrierQueueName, DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (id (^)(void))defaultInitializerForClass:(Class)clazz {
    return ^id {
        return [[clazz alloc] init];
    };
}

@end
