//
//  DCALAssetItem.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"

@interface DCALAssetItem : NSObject <DCDataItem>

@property (retain, nonatomic) ALAsset *alAsset;

@end
