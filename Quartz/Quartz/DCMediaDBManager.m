//
//  DCMediaDBManager.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaDBManager.h"
#import "DCMediaDBOperator.h"

static DCMediaDBManager *staticDefaultMediaDBManager = nil;


#pragma mark - interface DCMediaDBManager ()
@interface DCMediaDBManager () {
    NSMutableDictionary *_mediaDBOperatorPool;  // key: thread address; value: mediaDBOperator
}

- (void)cleanPool;

@end


#pragma mark - implementation DCMediaDBManager
@implementation DCMediaDBManager

#pragma mark - DCMediaDBManager - Public method
+ (DCMediaDBManager *)defaultManager {
    @synchronized (self) {
        if (!staticDefaultMediaDBManager) {
            staticDefaultMediaDBManager = [[super allocWithZone:nil] init];
        }
        
        return staticDefaultMediaDBManager;
    }
}

+ (void)staticRelease {
    @synchronized (self) {
        if (staticDefaultMediaDBManager) {
            [staticDefaultMediaDBManager cleanPool];
            dc_release(staticDefaultMediaDBManager);
            staticDefaultMediaDBManager = nil;
        }
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultManager];
}

- (void)dealloc {
    dc_dealloc(super);
}

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(_mediaDBOperatorPool) {
            if (!_mediaDBOperatorPool) {
                _mediaDBOperatorPool = [NSMutableDictionary dictionary];
            }
        }
    }
    return self;
}

- (DCMediaDBOperator *)queryMediaDBOperatorForThread:(NSThread *)aThread {
    DCMediaDBOperator *result = nil;
    do {
        if (!aThread) {
            break;
        }
        
        NSString *threadID = [NSString stringWithFormat:@"%8x", (NSUInteger)aThread];
        
        @synchronized(_mediaDBOperatorPool) {
            if (_mediaDBOperatorPool) {
                result = [_mediaDBOperatorPool objectForKey:threadID];
            }
            
            if (!result) {
                result = [[DCMediaDBOperator alloc] initWithThread:aThread andThreadID:threadID];
                if (result) {
                    [_mediaDBOperatorPool setObject:result forKey:threadID];
                }
            }
        }
    } while (NO);
    return result;
}

- (void)removeMediaDBOperatorForThread:(NSThread *)aThread {
    do {
        if (!aThread) {
            break;
        }
        
        NSString *threadID = [NSString stringWithFormat:@"%8x", (NSUInteger)aThread];
        
        @synchronized(_mediaDBOperatorPool) {
            if (_mediaDBOperatorPool) {
                [_mediaDBOperatorPool removeObjectForKey:threadID];
            }
        }
    } while (NO);
}

#pragma mark - DCMediaDBManager - Private method
- (void)cleanPool {
    do {
        @synchronized(_mediaDBOperatorPool) {
            if (_mediaDBOperatorPool) {
                [_mediaDBOperatorPool removeAllObjects];
                dc_release(_mediaDBOperatorPool);
                _mediaDBOperatorPool = nil;
            }
        }
    } while (NO);
}

@end