//
//  DCALAssetItem.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"

@interface DCALAssetItem : NSObject <DCDataItem>

@property (nonatomic, SAFE_ARC_PROP_STRONG)ALAsset *asset;

- (id)initWithALAsset:(ALAsset *)asset;

@end
