//
//  DCLoadThumbnailForALAssetItem.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCLoadThumbnailForALAssetItem : NSOperation

@property (retain, nonatomic) ALAsset *alAsset;
@property (retain, nonatomic) UIImage *thumbnail;

- (id)initWithALAsset:(ALAsset *)alAsset;

@end
