//
//  DCUniformDataProtocol.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark DCDataItem
extern NSString * const kDATAITEMPROPERTY_UID;
extern NSString * const kDATAITEMPROPERTY_FILENAME;
extern NSString * const kDATAITEMPROPERTY_URL;
extern NSString * const kDATAITEMPROPERTY_TYPE;
extern NSString * const kDATAITEMPROPERTY_DATE;
extern NSString * const kDATAITEMPROPERTY_ORIENTATION;
extern NSString * const kDATAITEMPROPERTY_THUMBNAIL;
extern NSString * const kDATAITEMPROPERTY_ORIGINIMAGE;
extern NSString * const kDATAITEMPROPERTY_FULLSCREENIMAGE;

@protocol DCDataItem <NSObject>

- (NSString *)uniqueID;

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;

- (NSOperation *)createOperationForLoadCacheThumbnail;

@end

#pragma mark DCDataGroup

extern NSString * const kDATAGROUPPROPERTY_UID;
extern NSString * const kDATAGROUPPROPERTY_GROUPNAME;
extern NSString * const kDATAGROUPPROPERTY_URL;
extern NSString * const kDATAGROUPPROPERTY_TYPE;
extern NSString * const kDATAGROUPPROPERTY_POSTERIMAGE;

@protocol DCDataGroup <NSObject>

- (NSString *)uniqueID;

- (void)clearCache;

- (void)enumItems:(id)param;

- (NSUInteger)itemsCount;

- (id <DCDataItem>)itemWithUID:(NSString *)uid;

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;

- (NSString *)itemUIDAtIndex:(NSUInteger)index;

- (NSUInteger)indexForItemUID:(NSString *)itemUID;

- (BOOL)isEnumerated;

@end

#pragma mark DCDataLibrary

@protocol DCDataLibrary <NSObject>

- (BOOL)connect:(NSDictionary *)params;

- (BOOL)disconnect;

- (void)clearCache;

- (void)enumGroups:(id)param;

- (NSUInteger)groupsCount;

- (id <DCDataGroup>)groupWithUID:(NSString *)uid;

- (NSString *)groupUIDAtIndex:(NSUInteger)index;

- (NSUInteger)indexForGroupUID:(NSString *)groupUID;

@end

#pragma mark DCDataLibraryHelper

@protocol DCDataLibraryHelper <NSObject>

+ (id)defaultDataLibraryHelper;

+ (void)staticRelease;

- (BOOL)connect:(NSDictionary *)params;

- (BOOL)disconnect;

- (void)clearCache;

- (void)enumGroups:(id)param;

- (NSUInteger)groupsCount;

- (id <DCDataGroup>)groupWithUID:(NSString *)uid;

- (NSString *)groupUIDAtIndex:(NSUInteger)index;

- (NSUInteger)indexForGroupUID:(NSString *)groupUID;

/*** *** ***/

- (void)clearCacheInGroup:(NSString *) groupUID;

- (void)enumItems:(id)param InGroup:(NSString *) groupUID;

- (NSUInteger)itemsCountInGroup:(NSString *) groupUID;

- (id <DCDataItem>)itemWithUID:(NSString *)uid inGroup:(NSString *) groupUID;

- (NSString *)itemUIDAtIndex:(NSUInteger)index inGroup:(NSString *) groupUID;

- (NSUInteger)indexForItemUID:(NSString *)itemUID inGroup:(NSString *) groupUID;

- (BOOL)isGroupEnumerated:(NSString *) groupUID;

@end

/*** *** ***/ /*** *** ***/ /*** *** ***/

//@interface DCUniformDataProtocol : NSObject
//
//@end
