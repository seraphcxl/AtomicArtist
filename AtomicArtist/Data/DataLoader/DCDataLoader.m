//
//  DCDataLoader.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCDataLoader.h"

#define VISIABLEOPERATIONQUEUE_DEFAULTCONCURRENTCOUNT ((NSInteger)2)
#define BUFFEROPERATIONQUEUE_DEFAULTCONCURRENTCOUNT ((NSInteger)1)

#define TIMEFORRESTART ((NSTimeInterval)1.0)

static DCDataLoader *staticDCDataLoader = nil;

@interface DCDataLoader () {
    NSOperationQueue *_queueForVisiable;
    NSTimer *_timerForRestartVisiable;
    
    NSOperationQueue *_queueForBuffer;
    NSTimer *_timerForRestartBuffer;
}

- (void)queue:(enum DATALODER_TYPE)type setSuspended:(BOOL)b;

- (void)queue:(enum DATALODER_TYPE)type setMaxConcurrentOperationCount:(NSInteger)cnt;

- (void)restart:(NSTimer *)timer;

- (void)resumeQueue:(enum DATALODER_TYPE)type;

- (void)removeTimerForVisiableQueue;

- (void)createTimerForVisiableQueue:(NSString *) timeStr;

- (void)removeTimerForBufferQueue;

- (void)createTimerForBufferQueue:(NSString *) timeStr;

@end

@implementation DCDataLoader

- (void)removeTimerForVisiableQueue {
    if (_timerForRestartVisiable) {
        [_timerForRestartVisiable invalidate];
        [_timerForRestartVisiable release];
        _timerForRestartVisiable = nil;
    }
}

- (void)removeTimerForBufferQueue {
    if (_timerForRestartBuffer) {
        [_timerForRestartBuffer invalidate];
        [_timerForRestartBuffer release];
        _timerForRestartBuffer = nil;
    }
}

- (void)createTimerForVisiableQueue:(NSString *)timeStr {
    NSInteger seconds = [timeStr integerValue];
    _timerForRestartVisiable = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(restart:) userInfo:nil repeats:NO];
    [_timerForRestartVisiable retain];
}

- (void)createTimerForBufferQueue:(NSString *)timeStr {
    NSInteger seconds = [timeStr integerValue];
    _timerForRestartBuffer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(restart:) userInfo:nil repeats:NO];
    [_timerForRestartBuffer retain];
}

- (void)restart:(NSTimer *)timer {
    if (_timerForRestartVisiable == timer) {
        NSLog(@"DCDataLoader restart visiable:");
        if (_queueForVisiable) {
            [_queueForVisiable setSuspended:NO];
        }
        [_timerForRestartVisiable invalidate];
        [_timerForRestartVisiable release];
        _timerForRestartVisiable = nil;
    } else if (_timerForRestartBuffer == timer) {
        NSLog(@"DCDataLoader restart buffer:");
        if (_queueForBuffer) {
            [_queueForBuffer setSuspended:NO];
        }
        [_timerForRestartBuffer invalidate];
        [_timerForRestartBuffer release];
        _timerForRestartBuffer = nil;
    }
}

- (void)queue:(enum DATALODER_TYPE)type addOperation:(NSOperation *)operation {
    if (operation) {
        if (type == DATALODER_TYPE_VISIABLE) {
            if (_queueForVisiable) {
                [_queueForVisiable addOperation:operation];
                NSLog(@"ops count in visiable queue: %d", [_queueForVisiable operationCount]);
            }
        } else if (type == DATALODER_TYPE_BUFFER) {
            if (_queueForBuffer) {
                [_queueForBuffer addOperation:operation];
                NSLog(@"ops count in buffer queue: %d", [_queueForBuffer operationCount]);
            }
        }
    }
}

- (void)cancelAllOperationsOnQueue:(enum DATALODER_TYPE)type {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            NSLog(@"DataLoader visiable queue cancelAllOperations");
            [_queueForVisiable cancelAllOperations];
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            NSLog(@"DataLoader buffer queue cancelAllOperations");
            [_queueForBuffer cancelAllOperations];
        }
    }
}

- (void)terminateAllOperationsOnQueue:(enum DATALODER_TYPE)type {
    [self queue:DATALODER_TYPE_VISIABLE pauseWithAutoResume:NO with:0.0];
    [self queue:DATALODER_TYPE_BUFFER pauseWithAutoResume:NO with:0.0];
    [self cancelAllOperationsOnQueue:type];
    [self resumeQueue:type];
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            [_queueForVisiable waitUntilAllOperationsAreFinished];
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            [_queueForBuffer waitUntilAllOperationsAreFinished];
        }
    }
}

- (NSUInteger)operationCountOnQueue:(enum DATALODER_TYPE)type {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            return [_queueForVisiable operationCount];
        } else {
            return 0;
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            return [_queueForBuffer operationCount];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (NSInteger)maxConcurrentOperationCountOnQueue:(enum DATALODER_TYPE)type {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            return [_queueForVisiable maxConcurrentOperationCount];
        } else {
            return 0;
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            return [_queueForBuffer maxConcurrentOperationCount];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (void)queue:(enum DATALODER_TYPE)type setMaxConcurrentOperationCount:(NSInteger)cnt {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            [_queueForVisiable setMaxConcurrentOperationCount:cnt];
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            [_queueForBuffer setMaxConcurrentOperationCount:cnt];
        }
    }
}

- (void)queue:(enum DATALODER_TYPE)type pauseWithAutoResume:(BOOL)enable with:(NSTimeInterval)seconds {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            [self queue:type setSuspended:YES];
            
            [self performSelectorOnMainThread:@selector(removeTimerForVisiableQueue) withObject:nil waitUntilDone:YES];
            
            if (enable) {
                NSString *timeStr = [NSString stringWithFormat:@"%d", seconds];
                [self performSelectorOnMainThread:@selector(createTimerForVisiableQueue:) withObject:timeStr waitUntilDone:YES];
            } else {
                NSLog(@"No auto resume");
            }
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            [self queue:type setSuspended:YES];
            
            [self performSelectorOnMainThread:@selector(removeTimerForBufferQueue) withObject:nil waitUntilDone:YES];
            
            if (enable) {
                NSString *timeStr = [NSString stringWithFormat:@"%d", seconds];
                [self performSelectorOnMainThread:@selector(createTimerForBufferQueue:) withObject:timeStr waitUntilDone:YES];
            } else {
                NSLog(@"No auto resume");
            }
        }
    }
}

- (void)resumeQueue:(enum DATALODER_TYPE)type {
    if ([self isSuspendedQueue:type]) {
        if (type == DATALODER_TYPE_VISIABLE) {
            if (_queueForVisiable) {
                NSLog(@"DCDataLoader resume visiable queue");
                [self performSelectorOnMainThread:@selector(removeTimerForVisiableQueue) withObject:nil waitUntilDone:YES];
            }
        } else if (type == DATALODER_TYPE_BUFFER) {
            if (_queueForBuffer) {
                NSLog(@"DCDataLoader resume buffer queue");
                [self performSelectorOnMainThread:@selector(removeTimerForBufferQueue) withObject:nil waitUntilDone:YES];
            }
        }
        [self queue:type setSuspended:NO];
    }
}

- (void)queue:(enum DATALODER_TYPE)type setSuspended:(BOOL)b {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            [_queueForVisiable setSuspended:b];
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            [_queueForBuffer setSuspended:b];
        }
    }
}

- (BOOL)isSuspendedQueue:(enum DATALODER_TYPE)type {
    if (type == DATALODER_TYPE_VISIABLE) {
        if (_queueForVisiable) {
            return [_queueForVisiable isSuspended];
        } else {
            return YES;
        }
    } else if (type == DATALODER_TYPE_BUFFER) {
        if (_queueForBuffer) {
            return [_queueForBuffer isSuspended];
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

+ (id)defaultDataLoader {
    if (!staticDCDataLoader) {
        staticDCDataLoader = [[super allocWithZone:nil] init];
    }
    
    return staticDCDataLoader;
}

+ (void)staticRelease {
    if (!staticDCDataLoader) {
        [staticDCDataLoader release];
        staticDCDataLoader = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultDataLoader];
}

- (id)init {
    self = [super init];
    if (self) {
        if (!_queueForVisiable) {
            _queueForVisiable = [[NSOperationQueue alloc] init];
            [self queue:DATALODER_TYPE_VISIABLE setMaxConcurrentOperationCount:VISIABLEOPERATIONQUEUE_DEFAULTCONCURRENTCOUNT];
        }
        
        if (!_queueForBuffer) {
            _queueForBuffer = [[NSOperationQueue alloc] init];
            [self queue:DATALODER_TYPE_BUFFER setMaxConcurrentOperationCount:BUFFEROPERATIONQUEUE_DEFAULTCONCURRENTCOUNT];
        }
    }
    return self;
}

- (void)dealloc {
    if (_timerForRestartVisiable) {
        [_timerForRestartVisiable invalidate];
        [_timerForRestartVisiable release];
        _timerForRestartVisiable = nil;
    }
    
    if (_timerForRestartBuffer) {
        [_timerForRestartBuffer invalidate];
        [_timerForRestartBuffer release];
        _timerForRestartBuffer = nil;
    }
    
    if (_queueForVisiable) {
        [_queueForVisiable release];
        _queueForVisiable = nil;
    }
    
    if (_queueForBuffer) {
        [_queueForBuffer release];
        _queueForBuffer = nil;
    }
    
    [super dealloc];
}

@end
