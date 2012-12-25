//
//  DCMediaLibManagerCoordinator.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaLibManagerCoordinator.h"
#import "DCMediaLibManager.h"

static DCMediaLibManagerCoordinator *staticDefaultCoordinator = nil;


#pragma mark - interface DCMediaLibManagerCoordinator ()
@interface DCMediaLibManagerCoordinator () {
    NSMutableDictionary *_mediaLibManagerPool;  // key: thread address; value: mediaLibManager
}

- (void)cleanPool;

@end


#pragma mark - implementation DCMediaLibManagerCoordinator
@implementation DCMediaLibManagerCoordinator

#pragma mark - DCMediaLibManagerCoordinator - Public method
+ (DCMediaLibManagerCoordinator *)defaultCoordinator {
    if (!staticDefaultCoordinator) {
        staticDefaultCoordinator = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultCoordinator;
}

+ (void)staticRelease {
    if (staticDefaultCoordinator) {
        [staticDefaultCoordinator cleanPool];
//        [staticDefaultCoordinator release];
        staticDefaultCoordinator = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultCoordinator];
}

- (void)dealloc {
//    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(_mediaLibManagerPool) {
            if (!_mediaLibManagerPool) {
                _mediaLibManagerPool = [NSMutableDictionary dictionary];
            }
        }
    }
    return self;
}

- (DCMediaLibManager *)queryMediaLibManagerForThread:(NSThread *)aThread {
    DCMediaLibManager *result = nil;
    do {
        if (!aThread) {
            break;
        }
        
        NSString *threadID = [NSString stringWithFormat:@"%8x", (NSUInteger)aThread];
        
        @synchronized(_mediaLibManagerPool) {
            if (_mediaLibManagerPool) {
                result = [_mediaLibManagerPool objectForKey:threadID];
            }
            
            if (!result) {
                result = [[DCMediaLibManager alloc] initWithThreadID:threadID];
                if (result) {
                    [_mediaLibManagerPool setObject:result forKey:threadID];
                }
            }
        }
    } while (NO);
    return result;
}

#pragma mark - DCMediaLibManagerCoordinator - Private method
- (void)cleanPool {
    do {
        @synchronized(_mediaLibManagerPool) {
            if (_mediaLibManagerPool) {
                [_mediaLibManagerPool removeAllObjects];
//                [_mediaLibManagerPool release];
                _mediaLibManagerPool = nil;
            }
        }
    } while (NO);
}

@end

