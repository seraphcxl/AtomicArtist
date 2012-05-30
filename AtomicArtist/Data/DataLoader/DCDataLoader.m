//
//  DCDataLoader.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCDataLoader.h"

#define OPERATIONQUEUE_DEFAULTCONCURRENTCOUNT ((NSInteger)2)

#define TIMEFORRESTART ((NSTimeInterval)1.0)

static DCDataLoader *staticDCDataLoader = nil;

@interface DCDataLoader () {
    NSOperationQueue *_operationQueue;
    
    NSTimer *_timerForRestart;
}

- (void)setSuspended:(BOOL)b;

- (void)restart:(NSTimer *)timer;

@end

@implementation DCDataLoader

- (void)restart:(NSTimer *)timer {
    if (_timerForRestart == timer) {
        NSLog(@"DCDataLoader restart:");
        if (_operationQueue) {
            [_operationQueue setSuspended:NO];
        }
        [_timerForRestart invalidate];
        [_timerForRestart release];
        _timerForRestart = nil;
    }
}

- (void)addOperation:(NSOperation *)operation {
    if (_operationQueue && operation) {
        [_operationQueue addOperation:operation];
    }
}

- (void)cancelAllOperations {
    if (_operationQueue) {
        [_operationQueue cancelAllOperations];
    }
}

- (NSUInteger)operationCount {
    if (_operationQueue) {
        return [_operationQueue operationCount];
    } else {
        return 0;
    }
}

- (NSInteger)maxConcurrentOperationCount {
    if (_operationQueue) {
        return [_operationQueue maxConcurrentOperationCount];
    } else {
        return -1;
    }
}

- (void)setMaxConcurrentOperationCount:(NSInteger)cnt {
    if (_operationQueue) {
        [_operationQueue setMaxConcurrentOperationCount:cnt];
    }
}

- (void)pauseWithAutoResumeIn:(NSTimeInterval)seconds {
    if (_operationQueue) {
        [self setSuspended:YES];
        NSLog(@"DCDataLoader setSuspended:YES");
        if (_timerForRestart) {
            [_timerForRestart invalidate];
            [_timerForRestart release];
            _timerForRestart = nil;
        }
        _timerForRestart = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(restart:) userInfo:nil repeats:NO];
        [_timerForRestart retain];
    }
}

- (void)setSuspended:(BOOL)b {
    if (_operationQueue) {
        [_operationQueue setSuspended:b];
    }
}

- (BOOL)isSuspended {
    if (_operationQueue) {
        return [_operationQueue isSuspended];
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
        if (!_operationQueue) {
            _operationQueue = [[NSOperationQueue alloc] init];
            [self setMaxConcurrentOperationCount:OPERATIONQUEUE_DEFAULTCONCURRENTCOUNT];
        }
    }
    return self;
}

- (void)dealloc {
    if (_timerForRestart) {
        [_timerForRestart invalidate];
        [_timerForRestart release];
        _timerForRestart = nil;
    }
    
    if (_operationQueue) {
        [_operationQueue release];
        _operationQueue = nil;
    }
    [super dealloc];
}

@end
