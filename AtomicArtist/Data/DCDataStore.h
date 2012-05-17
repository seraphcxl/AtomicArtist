//
//  DCDataStore.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Album;
@class Asset;

@interface DCDataStore : NSObject

+ (DCDataStore *)defaultStore;

+ (void)staticRelease;

- (NSString *)itemArchivePath;

- (Asset *)getAssetWithURL:(NSURL *)assetURL;

- (void)createAssetmWithURL:(NSURL *)assetURL andThumbnail:(UIImage *)thumbnail;

- (Album *)getAlbumWithURL:(NSURL *)albumURL;

- (void)createAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage;

- (void)updateAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage;

- (BOOL)saveChanges;

@end
