//
//  AADataStore.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@class Asset;

@interface AADataStore : NSObject

+ (AADataStore *)defaultStore;

+ (void)staticRelease;

- (NSString *)itemArchivePath;

- (Asset *)getAssetWithURL:(NSURL *)assetURL;

- (void)createAssetmWithURL:(NSURL *)assetURL andThumbnail:(UIImage *)thumbnail;

- (Album *)getAlbumWithURL:(NSURL *)albumURL;

- (void)createAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage;

- (void)updateAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage;

- (BOOL)saveChanges;

@end
