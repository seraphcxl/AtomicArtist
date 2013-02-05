//
//  DCALAssetsGroup.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCALAssetsGroupBase.h"

@interface DCALAssetsGroup : DCALAssetsGroupBase <DCDataGroup>

@property (nonatomic, SAFE_ARC_PROP_STRONG) ALAssetsGroup *assetsGroup;
@property (nonatomic, SAFE_ARC_PROP_STRONG) NSString *assetType;

- (id)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end
