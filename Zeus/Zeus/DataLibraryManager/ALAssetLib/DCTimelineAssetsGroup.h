//
//  DCTimelineAssetsGroup.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCALAssetsGroupBase.h"
#import "DCTimelineCommonConstants.h"

@class DCALAssetItem;

@interface DCTimelineAssetsGroup : DCALAssetsGroupBase <DCTimelineDataGroup> {
}

@property (nonatomic, assign) NSUInteger notifyhFrequency;

- (id)initWithGregorianUnitIntervalFineness:(GregorianUnitIntervalFineness) intervalFineness;

- (void)insertDataItem:(ALAsset *)asset;

@end
