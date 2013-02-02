//
//  DCAssetFaceFeatureLoader.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-24.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCFaceFeatureLoader.h"
#import "DCFaceFeatureLoader_Inner.h"
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DCAssetFaceFeatureLoader : DCFaceFeatureLoader

@property (nonatomic, SAFE_ARC_PROP_STRONG) ALAsset *asset;

@end
