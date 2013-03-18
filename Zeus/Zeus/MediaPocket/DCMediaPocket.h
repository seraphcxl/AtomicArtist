//
//  DCMediaPocket.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"
#import "DCMediaPocketDataProtocel.h"
#import "DCAssetsLibAgent.h"

@protocol CameraActionDelegate <NSObject>

- (NSInteger)takePhotoWithDataItem:(NSString *)dataItemUID;

@end

extern NSString * const NOTIFY_MEDIAPOCKET_INSERTED;
extern NSString * const NOTIFY_MEDIAPOCKET_REMOVED;
extern NSString * const NOTIFY_MEDIAPOCKET_REMOVEDFROMNOTIFICATION;
extern NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME;
extern NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF;

//extern NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERTED;
//extern NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPREMOVED;

extern NSString * const NOTIFY_MEDIAPOCKET_GROUPINGDONE;
extern NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERT_DONE;

extern NSString * const kDCMediaPocketSnapshotParam_ItemDict;
extern NSString * const kDCMediaPocketSnapshotParam_ItemArray;
extern NSString * const kDCMediaPocketSnapshotParam_TimelineGroupDict;

@class DCMediaBucket;

@interface DCMediaPocket : NSObject <DCAssetsLibUser> {
}

//DEFINE_SINGLETON_FOR_HEADER(DCMediaPocket);

+ (DCMediaPocket *)sharedDCMediaPocket;
+ (void)staticRelease;

@property (nonatomic, assign) id<CameraActionDelegate> cameraActionDelegate;
@property (atomic, assign, getter = isAllowRemoveWhenUseCountIsZero) BOOL allowRemoveWhenUseCountIsZero;
@property (atomic, strong, readonly) NSString *uniqueID;
@property (atomic, copy) NSString *insertingGroupUID;
@property (atomic, assign, getter = isMediaPocketGrouping) BOOL mediaPocketGrouping;

- (id)init;
- (void)reset;
- (void)clearUseCountForItems;

- (NSUInteger)itemCount;

- (id<DCMediaPocketDataItemProtocol>)findItem:(NSString *)uniqueID;
- (id<DCMediaPocketDataItemProtocol>)itemAtIndex:(NSUInteger)index;

- (void)updateItem:(id<DCMediaPocketDataItemProtocol>) item forUID:(NSString *)uniqueID;

- (void)increaseUseCountForItem:(NSString *)uniqueID;
- (void)decreaseUseCountForItem:(NSString *)uniqueID;

- (void)insertItem:(id<DCMediaPocketDataItemProtocol>)item atIndex:(NSUInteger)index;
- (void)topInsertItem:(id<DCMediaPocketDataItemProtocol>)item;
- (void)bottomInsertItem:(id<DCMediaPocketDataItemProtocol>)item;

- (void)removeItemAtIndex:(NSUInteger)index;
- (void)topRemoveItem;
- (void)bottomRemoveItem;
- (void)removeItem:(NSString *)uniqueID;

- (void)moveItemFrom:(NSUInteger)from to:(NSUInteger)to;

- (void)insertPhotoFromImagePicker:(CGImageRef)cgImg orientation:(ALAssetOrientation)assetOrientation;

- (void)insertItem:(NSString *)uniqueID withUseCount:(NSUInteger) useCount;

//- (void)insertTimelineGroup:(NSString *)uniqueID;
//- (void)removeTimelineGroup:(NSString *)uniqueID;
//- (BOOL)findTimelineGroup:(NSString *)uniqueID;
//- (NSUInteger)selectedTimelineGroupCount;

- (DCMediaPocket *)snapshot;
- (id)initByActionSnapshot:(NSDictionary *)params;

- (void)grouping;

- (NSUInteger)bucketCount;
- (DCMediaBucket *)bucket:(NSUInteger)idx;
- (DCMediaBucket *)bucketIncludeItem:(NSString *)uniqueID;

@end
