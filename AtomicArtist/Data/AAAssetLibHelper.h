//
//  AAAssetLibHelper.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAssetLibHelper : NSObject

+ (AAAssetLibHelper *)defaultAssetLibHelper;

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
