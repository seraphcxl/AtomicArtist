//
//  DCALAssetsLibrary.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"

@interface DCALAssetsLibrary : NSObject <DCDataLibrary>

@property (nonatomic, SAFE_ARC_PROP_STRONG) ALAssetsLibrary *assetsLibrary;

@end
