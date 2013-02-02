//
//  DCAssetsLibAgent.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-25.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"

#define DCASSETSLIBAGENT_UpdateNotification_StableDuration 2.0f

extern NSString *const DCAssetsLibStartChange;
extern NSString *const DCAssetsLibEndChange;

typedef enum {
    AssetsLibState_Valid = 0,
    AssetsLibState_Invalid,
} AssetsLibState;

@class DCAssetsLibAgent;

@protocol DCAssetsLibUser <NSObject>

- (void)nofityAssetsLibStable;

@end

@interface DCAssetsLibAgent : NSObject

@property (nonatomic, assign, readonly) AssetsLibState state;
@property (nonatomic, assign, readonly) NSUInteger version;

@property (nonatomic, SAFE_ARC_PROP_STRONG) ALAssetsLibrary *assetsLibrary;

DEFINE_SINGLETON_FOR_HEADER(DCAssetsLibAgent);

- (void)addAssetsLibUser:(id<DCAssetsLibUser>)user;
- (void)removeAssetsLibUser:(id<DCAssetsLibUser>)user;

@end
