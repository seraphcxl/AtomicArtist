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
extern NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME;
extern NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF;

@interface DCMediaPocket : NSObject <DCAssetsLibUser> {
}

DEFINE_SINGLETON_FOR_HEADER(DCMediaPocket);

@property (nonatomic, assign) id<CameraActionDelegate> cameraActionDelegate;
@property (atomic, assign, getter = isAllowRemoveWhenUseCountIsZero) BOOL allowRemoveWhenUseCountIsZero;

- (id)init;
- (void)reset;

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

@end
