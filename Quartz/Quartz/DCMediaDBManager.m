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
    if (!staticDefaultMediaDBManager) {
        staticDefaultMediaDBManager = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultMediaDBManager;
}

+ (void)staticRelease {
    if (staticDefaultMediaDBManager) {
        [staticDefaultMediaDBManager cleanPool];
//        [staticDefaultMediaDBManager release];
        staticDefaultMediaDBManager = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultManager];
}

- (void)dealloc {
//    [super dealloc];
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
                result = [[DCMediaDBOperator alloc] initWithThreadID:threadID];
                if (result) {
                    [_mediaDBOperatorPool setObject:result forKey:threadID];
                }
            }
        }
    } while (NO);
    return result;
}

#pragma mark - DCMediaDBManager - Private method
- (void)cleanPool {
    do {
        @synchronized(_mediaDBOperatorPool) {
            if (_mediaDBOperatorPool) {
                [_mediaDBOperatorPool removeAllObjects];
//                [_mediaDBOperatorPool release];
                _mediaDBOperatorPool = nil;
            }
        }
    } while (NO);
}

@end