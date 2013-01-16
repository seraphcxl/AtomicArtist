//
//  DCUniformDataProtocol.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DataSourceType_AssetsLib = 0,
    DataSourceType_Facebook,
} DataSourceType;

#pragma mark - Notify
extern NSString * const NOTIFY_DATAITEM_ADDED;
extern NSString * const NOTIFY_DATAITEM_ENUM_END;
extern NSString * const NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END;
extern NSString * const NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED;
extern NSString * const NOTIFY_DATAGROUP_ADDED;
extern NSString * const NOTIFY_DATAGROUP_ENUM_END;
extern NSString * const NOTIFY_DATAGROUP_EMPTY;

@protocol DCDataItem;

@protocol DCDataItemActionDelegate <NSObject>

- (void)notifyFileSaved:(id<DCDataItem>)dataItem to:(id)param;

@end

#pragma mark - DCDataItem - Property key
extern NSString * const kDATAITEMPROPERTY_UID;
extern NSString * const kDATAITEMPROPERTY_FILENAME;
extern NSString * const kDATAITEMPROPERTY_URL;
extern NSString * const kDATAITEMPROPERTY_TYPE;
extern NSString * const kDATAITEMPROPERTY_DATE;
extern NSString * const kDATAITEMPROPERTY_ORIENTATION;
extern NSString * const kDATAITEMPROPERTY_THUMBNAIL;
extern NSString * const kDATAITEMPROPERTY_ORIGINIMAGE;
extern NSString * const kDATAITEMPROPERTY_FULLSCREENIMAGE;
extern NSString * const kDATAITEMPROPERTY_THUMBNAILURL;

@protocol DCDataItem <NSObject>

@property (nonatomic, assign) id<DCDataItemActionDelegate> actionDelegate;

- (DataSourceType)type;
- (NSString *)uniqueID;
- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;
- (void)save:(NSString *)filePath;

@end

#pragma mark - DCDataGroup - Property key
extern NSString * const kDATAGROUPPROPERTY_UID;
extern NSString * const kDATAGROUPPROPERTY_GROUPNAME;
extern NSString * const kDATAGROUPPROPERTY_URL;
extern NSString * const kDATAGROUPPROPERTY_TYPE;
extern NSString * const kDATAGROUPPROPERTY_POSTERIMAGE;
extern NSString * const kDATAGROUPPROPERTY_POSTERIMAGEURL;

@protocol DCDataGroup <NSObject>

- (DataSourceType)type;
- (NSString *)uniqueID;
- (void)clearCache;
- (void)enumItems:(id)param notifyWithFrequency:(NSUInteger)frequency;
- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param notifyWithFrequency:(NSUInteger)frequency;
- (NSUInteger)itemsCountWithParam:(id)param;
- (NSUInteger)enumratedItemsCountWithParam:(id)param;
- (id<DCDataItem>)itemWithUID:(NSString *)uid;
- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;
- (NSString *)itemUIDAtIndex:(NSUInteger)index;
- (NSInteger)indexForItemUID:(NSString *)itemUID;
- (BOOL)isEnumerated;
- (BOOL)isEnumerating;

@end

#pragma mark - DCDataLibrary
@protocol DCDataLibrary <NSObject>

- (DataSourceType)type;
- (BOOL)connect:(NSDictionary *)params;
- (BOOL)disconnect;
- (void)clearCache;
- (void)enumGroups:(id)groupParam notifyWithFrequency:(NSUInteger)frequency;
- (NSUInteger)groupsCount;
- (id<DCDataGroup>)groupWithUID:(NSString *)uid;
- (NSString *)groupUIDAtIndex:(NSUInteger)index;
- (NSInteger)indexForGroupUID:(NSString *)groupUID;
- (BOOL)isEnumerating;

@end

//@interface DCUniformDataProtocol : NSObject
//
//@end
