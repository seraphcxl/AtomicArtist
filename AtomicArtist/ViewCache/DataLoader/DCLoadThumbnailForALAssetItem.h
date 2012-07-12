//
//  DCLoadThumbnailForALAssetItem.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCLoadThumbnailOperation.h"

@interface DCLoadThumbnailForALAssetItem : DCLoadThumbnailOperation

@property (readonly, nonatomic) ALAsset *alAsset;

- (id)initWithItemUID:(NSString *)itemUID andALAsset:(ALAsset *)alAsset;

@end
