//
//  DCFaceFeatureHelper.m
//  Hera
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCFaceFeatureHelper.h"
#import "DCMediaDBManager.h"
#import "DCMediaDBOperator.h"
#import "Item.h"
#import "DCFaceFeature.h"
#import "DCAssetFaceFeatureLoader.h"
#import "DCLocalFileFaceFeatureLoader.h"
#import "DCLoaderWorkshop.h"
#import "DCMediaPocket.h"

NSString * const NOTIFY_FACEFEATURE_DETECTED = @"NOTIFY_FACEFEATURE_DETECTED";

NSString * const kFACEFEATURE_DATAITEM_UID = @"FACEFEATURE_DATAITEM_UID";
NSString * const kFACEFEATURE_RECT_TOP = @"FACEFEATURE_RECT_TOP";
NSString * const kFACEFEATURE_RECT_BOTTOM = @"FACEFEATURE_RECT_BOTTOM";
NSString * const kFACEFEATURE_RECT_LEFT = @"FACEFEATURE_RECT_LEFT";
NSString * const kFACEFEATURE_RECT_RIGHT = @"FACEFEATURE_RECT_RIGHT";

@interface DCFaceFeatureHelper () {
}

- (BOOL)getFaceBoundingRectfromMediaDBForDataItem:(NSString *)dataItemUID forDict:(NSMutableDictionary *)dict;

- (void)detectFaceFeaturesBackground:(NSString *)dataItemUID;

- (void)actionForFaceFeatureLoaderDone:(NSNotification *)notification;

@end

@implementation DCFaceFeatureHelper

DEFINE_SINGLETON_FOR_CLASS(DCFaceFeatureHelper);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(actionForFaceFeatureLoaderDone:) name:NOTIFY_FACEFEATURELOADER_DONE object:nil];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter removeObserver:self];
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)actionForFaceFeatureLoaderDone:(NSNotification *)notification {
    do {
        @synchronized(self) {
            if (!notification || !notification.object) {
                break;
            }
            NSMutableDictionary *dict = (NSMutableDictionary *)notification.object;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_FACEFEATURE_DETECTED object:dict];
//            NSString *uid = (NSString *)notification.object;
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            if (!dict) {
//                break;
//            }
//            if (![self getFaceBoundingRectfromMediaDBForDataItem:uid forDict:dict]) {
//                SAFE_ARC_SAFERELEASE(dict);
//            } else {
//                if ([dict count] == 0) {
//                    SAFE_ARC_SAFERELEASE(dict);
//                } else {
//                    SAFE_ARC_AUTORELEASE(dict);
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_FACEFEATURE_DETECTED object:dict];
//                }
//            }
        }
    } while (NO);
}

- (NSDictionary *)detectFaceFeaturesForDataItem:(NSString *)dataItemUID {
    NSMutableDictionary *result = nil;
    do {
        @synchronized(self) {
            if (!dataItemUID) {
                break;
            }
            result = [[NSMutableDictionary alloc] init];
            if (!result) {
                break;
            }
            if (![self getFaceBoundingRectfromMediaDBForDataItem:dataItemUID forDict:result]) {
                SAFE_ARC_SAFERELEASE(result);
                [self detectFaceFeaturesBackground:dataItemUID];
            } else {
                if ([result count] == 0) {
                    SAFE_ARC_SAFERELEASE(result);
                } else {
                    SAFE_ARC_AUTORELEASE(result);
                }
            }
        }
    } while (NO);
    return result;
}

- (BOOL)getFaceBoundingRectfromMediaDBForDataItem:(NSString *)dataItemUID forDict:(NSMutableDictionary *)dict {
    BOOL result = NO;
    do {
        @synchronized(self) {
            DCMediaDBOperator *mediaDBOperator = [[DCMediaDBManager sharedDCMediaDBManager] queryMediaDBOperatorForThread:[NSThread currentThread]];
            Item *item = [mediaDBOperator getItemWithUID:dataItemUID];
            if (item) {
                result = YES;
                if ([item.faceFeatureArray count] == 0) {
                    ;
                } else {
                    float top = -1.0;
                    float bottom = -1.0;
                    float left = -1.0;
                    float right = -1.0;
                    [DCFaceFeature calcBoundingRectangle:item.faceFeatureArray withTop:&top bottom:&bottom left:&left right:&right];
                    [dict setObject:dataItemUID forKey:kFACEFEATURE_DATAITEM_UID];
                    [dict setObject:[NSNumber numberWithFloat:top] forKey:kFACEFEATURE_RECT_TOP];
                    [dict setObject:[NSNumber numberWithFloat:bottom] forKey:kFACEFEATURE_RECT_BOTTOM];
                    [dict setObject:[NSNumber numberWithFloat:left] forKey:kFACEFEATURE_RECT_LEFT];
                    [dict setObject:[NSNumber numberWithFloat:right] forKey:kFACEFEATURE_RECT_RIGHT];
                }
            }
        }
    } while (NO);
    return result;
}

- (void)detectFaceFeaturesBackground:(NSString *)dataItemUID {
    do {
        @synchronized(self) {
            if (!dataItemUID) {
                break;
            }
            
            id<DCMediaPocketDataItemProtocol> item = [[DCMediaPocket sharedDCMediaPocket] findItem:dataItemUID];
            DCFaceFeatureLoader *ffLoader = nil;
            switch ([item type]) {
                case DataSourceType_AssetsLib:
                {
                    DCAssetFaceFeatureLoader *aff = [[DCAssetFaceFeatureLoader alloc] init];
                    SAFE_ARC_AUTORELEASE(aff);
                    aff.uid = [item uniqueID];
                    aff.asset = (ALAsset *)[item origin];
                    aff.pixelSize = FACEFEATURE_PIXELSIZE;
                    ffLoader = aff;
                    SAFE_ARC_RETAIN(ffLoader);
                    SAFE_ARC_AUTORELEASE(ffLoader);
                }
                    break;
                    
                default:
                    break;
            }
            if (ffLoader) {
                [[DCLoaderWorkshop sharedDCLoaderWorkshop] addOperation:ffLoader toPipeline:DCLoaderUID_FaceFeature];
            }
        }
    } while (NO);
}

@end
