//
//  Quartz.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-4.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "Quartz.h"
#import "MediaLibManger.h"

static Quartz *staticDefaultQuartz = nil;


#pragma mark - interface Quartz ()
@interface Quartz () {
    NSMutableDictionary *_mediaLibMangerPool;  // key: thread address; value: mediaLibManger
}

- (void)cleanPool;

@end


#pragma mark - implementation Quartz
@implementation Quartz

#pragma mark - Quartz - Public method
+ (Quartz *)defaultQuartz {
    if (!staticDefaultQuartz) {
        staticDefaultQuartz = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultQuartz;
}

+ (void)staticRelease {
    if (staticDefaultQuartz) {
        [staticDefaultQuartz cleanPool];
//        [staticDefaultQuartz release];
        staticDefaultQuartz = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultQuartz];
}

- (void)dealloc {
//    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(_mediaLibMangerPool) {
            if (!_mediaLibMangerPool) {
                _mediaLibMangerPool = [NSMutableDictionary dictionary];
            }
        }
    }
    return self;
}

- (MediaLibManger *)queryMediaLibMangerForThread:(NSThread *)aThread {
    MediaLibManger *result = nil;
    do {
        if (!aThread) {
            break;
        }
        
        NSString *threadID = [NSString stringWithFormat:@"%8x", (NSUInteger)aThread];
        
        @synchronized(_mediaLibMangerPool) {
            if (_mediaLibMangerPool) {
                result = [_mediaLibMangerPool objectForKey:threadID];
            }
            
            if (!result) {
                result = [[MediaLibManger alloc] initWithThreadID:threadID];
                if (result) {
                    [_mediaLibMangerPool setObject:result forKey:threadID];
                }
            }
        }
    } while (NO);
    return result;
}

#pragma mark - Quartz - Private method
- (void)cleanPool {
    do {
        @synchronized(_mediaLibMangerPool) {
            if (_mediaLibMangerPool) {
                [_mediaLibMangerPool removeAllObjects];
//                [_mediaLibMangerPool release];
                _mediaLibMangerPool = nil;
            }
        }
    } while (NO);
}

@end
