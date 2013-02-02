//
//  DCAssetsLibAgent.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-25.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCAssetsLibAgent.h"

NSString *const DCAssetsLibStartChange = @"DCAssetsLibStartChange";
NSString *const DCAssetsLibEndChange = @"DCAssetsLibEndChange";

@interface DCAssetsLibAgent () {
    NSTimer *_timerForStable;
    
    NSMutableArray *_userArray;
}

- (void)assetsLibChanged:(NSNotification *)notification;
- (void)assetsLibStable:(NSTimer *)timer;
@end

@implementation DCAssetsLibAgent

@synthesize state = _state;
@synthesize version = _version;
@synthesize assetsLibrary = _assetsLibrary;

DEFINE_SINGLETON_FOR_CLASS(DCAssetsLibAgent);

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(self) {
            if (!_assetsLibrary) {
                _assetsLibrary = [[ALAssetsLibrary alloc] init];
            }
            
            _version = 0;
            
            if (_userArray) {
                [_userArray removeAllObjects];
                SAFE_ARC_SAFERELEASE(_userArray);
            }
            
            _userArray = [[NSMutableArray alloc] init];
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(assetsLibChanged:) name:ALAssetsLibraryChangedNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter removeObserver:self];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (_timerForStable) {
                    [_timerForStable invalidate];
                    SAFE_ARC_SAFERELEASE(_timerForStable);
                }
            });
            
            if (_userArray) {
                [_userArray removeAllObjects];
                SAFE_ARC_SAFERELEASE(_userArray);
            }
            
            SAFE_ARC_SAFERELEASE(_assetsLibrary);
            
            SAFE_ARC_SUPER_DEALLOC();
        }
    } while (NO);
}

- (void)addAssetsLibUser:(id<DCAssetsLibUser>)user {
    do {
        @synchronized(self) {
            [self removeAssetsLibUser:user];
            [_userArray addObject:user];
        }
    } while (NO);
}

- (void)removeAssetsLibUser:(id<DCAssetsLibUser>)user {
    do {
        @synchronized(self) {
            [_userArray removeObject:user];
        }
    } while (NO);
}

- (void)assetsLibChanged:(NSNotification *)notification {
    do {
        @synchronized(self) {
            ++_version;
            
            if (self.state == AssetsLibState_Valid) {
                _state = AssetsLibState_Invalid;
                [[NSNotificationCenter defaultCenter] postNotificationName:DCAssetsLibStartChange object:nil];
            } else if (self.state == AssetsLibState_Invalid) {
                ;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (_timerForStable) {
                    [_timerForStable invalidate];
                    SAFE_ARC_SAFERELEASE(_timerForStable);
                }
                _timerForStable = [NSTimer scheduledTimerWithTimeInterval:DCASSETSLIBAGENT_UpdateNotification_StableDuration target:self selector:@selector(assetsLibStable:) userInfo:nil repeats:NO];
                SAFE_ARC_RETAIN(_timerForStable);
            });
        }
    } while (NO);
}

- (void)assetsLibStable:(NSTimer *)timer {  // attention: this func should run in background thread
    do {
        @synchronized(self) {
            if (_timerForStable == timer) {
                NSAssert(self.state == AssetsLibState_Invalid, @"state error");
                _state = AssetsLibState_Valid;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                    SAFE_ARC_SAFERELEASE(_assetsLibrary);
                    if (!_assetsLibrary) {
                        _assetsLibrary = [[ALAssetsLibrary alloc] init];
                    }
                    
                    [_userArray makeObjectsPerformSelector:@selector(nofityAssetsLibStable)];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DCAssetsLibEndChange object:nil];
                });
                
                [_timerForStable invalidate];
                SAFE_ARC_SAFERELEASE(_timerForStable);
            }
        }
    } while (NO);
}

@end
