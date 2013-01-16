//
//  DCAssetsLibNotificationAgent.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-16.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"

#define DCASSETSLIBNOTIFICATIONAGENT_StableDuration 2.0f

extern NSString *const DCAssetsLibStartChange;
extern NSString *const DCAssetsLibEndChange;

typedef enum {
    AssetsLibState_Valid = 0,
    AssetsLibState_Invalid,
} AssetsLibState;

@class DCAssetsLibNotificationAgent;

@protocol DCAssetsLibDataSource <NSObject>

- (void)nofityAssetsLibStable;

@end

@interface DCAssetsLibNotificationAgent : NSObject

@property (nonatomic, assign) id<DCAssetsLibDataSource> assetsLibDataSource;
@property (nonatomic, assign, readonly) AssetsLibState state;

DEFINE_SINGLETON_FOR_HEADER(DCAssetsLibNotificationAgent);

@end
