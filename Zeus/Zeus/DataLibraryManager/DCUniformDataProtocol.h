//
//  DCUniformDataProtocol.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SafeARC.h"
#import "DCTimelineCommonConstants.h"

typedef enum {
    DataSourceType_Unknown = 0,
    DataSourceType_AssetsLib,
    DataSourceType_Facebook,
    DataSourceType_Flickr,
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
extern NSString * const kDATAITEMPREFIX_AssetsLib;

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
extern NSString * const kDATAITEMPROPERTY_PROPERTYDATE;

#pragma mark - protocol DCDataItem <NSObject>
@protocol DCDataItem <NSObject>

@property (nonatomic, assign) id<DCDataItemActionDelegate> actionDelegate;

- (DataSourceType)type;
- (NSString *)uniqueID;
- (id)origin;
- (NSString *)md5;
- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;
- (void)save:(NSString *)filePath;

@end

/**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/

#pragma mark - DCDataGroup - Property key
extern NSString * const kDATAGROUPPROPERTY_UID;
extern NSString * const kDATAGROUPPROPERTY_GROUPNAME;
extern NSString * const kDATAGROUPPROPERTY_URL;
extern NSString * const kDATAGROUPPROPERTY_TYPE;
extern NSString * const kDATAGROUPPROPERTY_POSTERIMAGE;
extern NSString * const kDATAGROUPPROPERTY_POSTERIMAGEURL;

#pragma mark - protocol DCDataGroupBase <NSObject>
@protocol DCDataGroupBase <NSObject>

- (DataSourceType)type;
- (NSString *)uniqueID;
- (void)clearCache;
- (NSUInteger)itemsCountWithParam:(id)param;
- (id<DCDataItem>)itemWithUID:(NSString *)uniqueID;
- (NSString *)itemUIDAtIndex:(NSUInteger)index;
- (NSInteger)indexForItemUID:(NSString *)itemUID;

@end

#pragma mark - protocol DCDataGroup <DCDataGroupBase>
@protocol DCDataGroup <DCDataGroupBase>

- (void)enumItems:(id)param notifyWithFrequency:(NSUInteger)frequency;
- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param notifyWithFrequency:(NSUInteger)frequency;
- (NSUInteger)enumratedItemsCountWithParam:(id)param;
- (BOOL)isEnumerated;
- (BOOL)isEnumerating;
- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options;

@end

#pragma mark - protocol DCTimelineDataGroup <DCDataGroupBase>
#define DCTimelineDataGroup_CountForRefine (48)
@protocol DCTimelineDataGroup <DCDataGroupBase>

@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) NSDate *earliestTime;
@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) NSDate *latestTime;
@property (nonatomic, assign, readonly) CFGregorianUnits currentTimeInterval;
@property (nonatomic, assign, readonly) GregorianUnitIntervalFineness intervalFineness;

- (void)refining:(NSMutableArray *)refinedGroups withTimeInterval:(CFGregorianUnits)gregorianUnit;

@end

/**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ /**/ 

#pragma mark - protocol DCDataLibraryBase <NSObject>
@protocol DCDataLibraryBase <NSObject>

- (DataSourceType)type;
- (BOOL)connect:(NSDictionary *)params;
- (BOOL)disconnect;
- (void)clearCache;
- (NSUInteger)groupsCount;
- (id<DCDataGroupBase>)groupWithUID:(NSString *)uniqueID;
- (NSString *)groupUIDAtIndex:(NSUInteger)index;
- (NSInteger)indexForGroupUID:(NSString *)groupUID;
- (BOOL)isEnumerating;

@end

#pragma mark - protocol DCDataLibrary <DCDataLibraryBase>
@protocol DCDataLibrary <DCDataLibraryBase>

- (void)enumGroups:(id)groupParam notifyWithFrequency:(NSUInteger)frequency;

@end

#pragma mark - protocol DCTimelineDataLibrary <DCDataLibraryBase>
@protocol DCTimelineDataLibrary <DCDataLibraryBase>

@property (nonatomic, assign, readonly) CFGregorianUnits refinedGregorianUnit;

- (void)enumTimelineNotifyWithFrequency:(NSUInteger)frequency;
- (void)enumTimelineAtIndexes:(NSIndexSet *)indexSet notifyWithFrequency:(NSUInteger)frequency;

@end

//@interface DCUniformDataProtocol : NSObject
//
//@end
