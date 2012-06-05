//
//  DCALAssetsGroup.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"

@interface DCALAssetsGroup : NSObject <DCDataGroup>

@property (readonly, nonatomic) ALAssetsGroup *alAssetsGroup;
@property (readonly, nonatomic) NSString *assetType;

- (id)initWithALAssetsGroup:(ALAssetsGroup *)alAssetsGroup andAssetType:(NSString *)assetType;

@end
