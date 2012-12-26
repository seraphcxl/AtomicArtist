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

@interface DCALAssetsGroup : NSObject <DCDataGroup>

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSString *assetType;

- (id)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end
