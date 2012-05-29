//
//  DCDataLoader.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCDataLoader.h"

#define OPERATIONQUEUE_DEFAULTCONCURRENTCOUNT ((NSInteger)2)

static DCDataLoader *staticDCDataLoader = nil;

@interface DCDataLoader () {
    NSOperationQueue *_operationQueue;
}

@end

@implementation DCDataLoader

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
    if (_operationQueue) {
        [_operationQueue release];
        _operationQueue = nil;
    }
    [super dealloc];
}

@end
