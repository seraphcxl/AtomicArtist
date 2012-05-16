//
//  AAAssetsGroup.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/6/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAssetsGroup : NSObject

@property (retain, nonatomic) ALAssetsGroup *assetsGroup;

- (NSArray *)allAssets;

- (BOOL)enumerateAssets;

- (ALAsset *)getALAssetForAssetURL:(NSURL *)assetURL;

- (void)cleaeCache;

- (NSUInteger)assetCount;

- (NSURL *)getAssetURLAtIndex:(NSUInteger)index;

- (NSUInteger)getIndexForAssetURL:(NSURL *)assetURL;

@end
