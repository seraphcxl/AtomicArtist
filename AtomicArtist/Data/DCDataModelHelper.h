//
//  DCDataModelHelper.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@class Group;

@interface DCDataModelHelper : NSObject

+ (DCDataModelHelper *)defaultDataModelHelper;

+ (void)staticRelease;

- (NSString *)itemArchivePath;

- (Item *)getItemWithUID:(NSString *)itemUID;

- (void)createItemWithUID:(NSString *)itemUID andThumbnail:(UIImage *)thumbnail;

- (Group *)getGroupWithUID:(NSString *)groupUID;

- (void)createGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage;

- (void)updateGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage;

- (BOOL)saveChanges;

@end
