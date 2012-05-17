//
//  DCAssetLibHelper.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCAssetLibHelper : NSObject

+ (DCAssetLibHelper *)defaultAssetLibHelper;

+ (void)staticRelease;

- (void)createAssetLibHelper;

- (void)releaseAssetLibHelper;

- (void)cleaeCache;

- (void)cleaeCacheForGoupPersistentID:(NSString *)groupPersistentID;

- (BOOL)enumerateGroupsWithTypes:(ALAssetsGroupType)types;

- (BOOL)enumerateAssetsForGoupPersistentID:(NSString *)groupPersistentID;

- (ALAssetsGroup *)getALGroupForGoupPersistentID:(NSString *)groupPersistentID;

- (NSString *)getGoupPersistentIDAtIndex:(NSUInteger)index;

- (ALAsset *)getALAssetForGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL;

- (NSURL *)getAssetURLForGoupPersistentID:(NSString *)groupPersistentID atIndex:(NSUInteger)index;

- (NSUInteger)assetsGroupCount;

- (NSUInteger)assetCountForGroupWithPersistentID:(NSString *)groupPersistentID;

- (NSUInteger)getIndexInGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL;

@end
