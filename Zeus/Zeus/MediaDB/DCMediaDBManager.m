//
//  DCMediaDBManager.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaDBManager.h"
#import "DCMediaDBOperator.h"

#pragma mark - interface DCMediaDBManager ()
@interface DCMediaDBManager () {
    NSMutableDictionary *_mediaDBOperatorPool;  // key: thread address; value: mediaDBOperator
}

- (void)cleanPool;

@end


#pragma mark - implementation DCMediaDBManager
@implementation DCMediaDBManager

#pragma mark - DCMediaDBManager - Public method

DEFINE_SINGLETON_FOR_CLASS(DCMediaDBManager);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            if (!_mediaDBOperatorPool) {
                _mediaDBOperatorPool = [NSMutableDictionary dictionary];
                SAFE_ARC_RETAIN(_mediaDBOperatorPool);
            }
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            [self cleanPool];
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (DCMediaDBOperator *)queryMediaDBOperatorForThread:(NSThread *)aThread {
    DCMediaDBOperator *result = nil;
    do {
        if (!aThread) {
            break;
        }
        
        NSString *threadID = [NSString stringWithFormat:@"%8x", (NSUInteger)aThread];
        
        @synchronized(self) {
            if (_mediaDBOperatorPool) {
                result = [_mediaDBOperatorPool objectForKey:threadID];
            }
            
            if (!result) {
                result = [[DCMediaDBOperator alloc] initWithThread:aThread andThreadID:threadID];
                SAFE_ARC_AUTORELEASE(result);
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
        
        @synchronized(self) {
            if (_mediaDBOperatorPool) {
                [_mediaDBOperatorPool removeObjectForKey:threadID];
            }
        }
    } while (NO);
}

#pragma mark - DCMediaDBManager - Private method
- (void)cleanPool {
    do {
        @synchronized(self) {
            if (_mediaDBOperatorPool) {
                [_mediaDBOperatorPool removeAllObjects];
                SAFE_ARC_SAFERELEASE(_mediaDBOperatorPool);
            }
        }
    } while (NO);
}

@end