//
//  DCAssetsGroup.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 serapgCXL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCAssetsGroup : NSObject

@property (retain, nonatomic) ALAssetsGroup *assetsGroup;

- (NSArray *)allAssets;

- (BOOL)enumerateAssets;

- (ALAsset *)getALAssetForAssetURL:(NSURL *)assetURL;

- (void)cleaeCache;

- (NSUInteger)assetCount;

- (NSURL *)getAssetURLAtIndex:(NSUInteger)index;

- (NSUInteger)getIndexForAssetURL:(NSURL *)assetURL;

@end

