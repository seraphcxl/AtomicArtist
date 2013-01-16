//
//  DCAssetsLibNotificationAgent.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-16.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCAssetsLibNotificationAgent.h"

NSString *const DCAssetsLibStartChange = @"DCAssetsLibStartChange";
NSString *const DCAssetsLibEndChange = @"DCAssetsLibEndChange";

@interface DCAssetsLibNotificationAgent () {
    NSTimer *_timerForStable;
}

- (void)assetsLibChanged:(NSNotification *)notification;
- (void)assetsLibStable:(NSTimer *)timer;
@end

@implementation DCAssetsLibNotificationAgent

@synthesize assetsLibDataSource = _assetsLibDataSource;
@synthesize state = _state;

DEFINE_SINGLETON_FOR_CLASS(DCAssetsLibNotificationAgent);

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(self) {
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
            
            self.assetsLibDataSource = nil;
            
            SAFE_ARC_SUPER_DEALLOC();
        }
    } while (NO);
}

- (void)assetsLibChanged:(NSNotification *)notification {
    do {
        @synchronized(self) {
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
                _timerForStable = [NSTimer scheduledTimerWithTimeInterval:DCASSETSLIBNOTIFICATIONAGENT_StableDuration target:self selector:@selector(assetsLibStable:) userInfo:nil repeats:NO];
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
                    [self.assetsLibDataSource nofityAssetsLibStable];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DCAssetsLibEndChange object:nil];
                });
                
                [_timerForStable invalidate];
                SAFE_ARC_SAFERELEASE(_timerForStable);
            }
        }
    } while (NO);
}

@end
