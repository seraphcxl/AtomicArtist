//
//  DCUniformDataProtocol.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark DCDataItem
typedef enum {
    DATAITEMPROPERTY_UID,
    DATAITEMPROPERTY_FILENAME,
    DATAITEMPROPERTY_URL,
    DATAITEMPROPERTY_TYPE,
    DATAITEMPROPERTY_DATE,
    DATAITEMPROPERTY_ORIENTATION,
    DATAITEMPROPERTY_THUMBNAIL,
    DATAITEMPROPERTY_ORIGINIMAGE,
    DATAITEMPROPERTY_FULLSCREENIMAGE,
} DATAITEMPROPERTY;

@protocol DCDataItem <NSObject>

- (NSString *)uniqueID;

- (id)valueForProperty:(DATAITEMPROPERTY)property;

@end

#pragma mark DCDataGroup
typedef enum {
    DATAGROUPPROPERTY_UID,
    DATAGROUPPROPERTY_GROUPNAME,
    DATAGROUPPROPERTY_URL,
    DATAGROUPPROPERTY_TYPE,
    DATAGROUPPROPERTY_POSTERIMAGE,
} DATAGROUPPROPERTY;

@protocol DCDataGroup <NSObject>

- (NSString *)uniqueID;

- (void)clearCache;

- (void)enumItems:(id)param;

- (NSUInteger)itemsCount;

- (id)itemWithUID:(NSString *)uid;

- (id)valueForProperty:(DATAGROUPPROPERTY)property;

- (NSString *)itemUIDAtIndex:(NSUInteger)index;

- (NSUInteger)indexForItemUID:(NSString *)itemUID;

@end

#pragma mark DCDataLibrary

@protocol DCDataLibrary <NSObject>

- (BOOL)connect:(NSDictionary *)params;

- (BOOL)disconnect;

- (void)clearCache;

- (void)enumGroups:(id)param;

- (NSUInteger)groupsCount;

- (id)groupWithUID:(NSString *)uid;

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

- (id)groupWithUID:(NSString *)uid;

- (NSString *)groupUIDAtIndex:(NSUInteger)index;

- (NSUInteger)indexForGroupUID:(NSString *)groupUID;

/*** *** ***/

- (void)clearCacheInGroup:(NSString *) groupUID;

- (void)enumItems:(id)param InGroup:(NSString *) groupUID;

- (NSUInteger)itemsCountInGroup:(NSString *) groupUID;

- (id)itemWithUID:(NSString *)uid inGroup:(NSString *) groupUID;

- (NSString *)itemUIDAtIndex:(NSUInteger)index inGroup:(NSString *) groupUID;

- (NSUInteger)indexForItemUID:(NSString *)itemUID inGroup:(NSString *) groupUID;

@end

