//
//  DCTimelineAssetsGroup.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCTimelineAssetsGroup.h"
#import "DCALAssetItem.h"

@interface DCTimelineAssetsGroup () {
}

@end

@implementation DCTimelineAssetsGroup

@synthesize earliestTime = _earliestTime;
@synthesize latestTime = _latestTime;
@synthesize notifyhFrequency = _notifyhFrequency;

- (void)insertDataItem:(ALAsset *)asset {
    do {
        @synchronized(self) {
            if (!_allAssetItems || !_allAssetUIDs) {
                [NSException raise:@"DCTimelineAssetsGroup Error" format:@"Reason: _allAssetItems == nil || _allAssetUIDs == nil"];
                break;
            }
            if (!asset) {
                NSUInteger count = [_allAssetUIDs count];
                if (count != (count / self.notifyhFrequency) * self.notifyhFrequency) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END object:self];
            } else {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                NSURL *url = [representation url];
                NSString *assetURLStr = [url absoluteString];
                
                DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:asset];
                [_allAssetItems setObject:item forKey:assetURLStr];
                NSUInteger indexForAsset = [_allAssetUIDs count];
                [_allAssetUIDs insertObject:assetURLStr atIndex:indexForAsset];
                NSUInteger count = [_allAssetUIDs count];
                if (count == (count / self.notifyhFrequency) * self.notifyhFrequency) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                }
            }
        }
    } while (NO);
}

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_earliestTime);
            SAFE_ARC_SAFERELEASE(_latestTime);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCTimelineDataGroup
- (void)refining:(NSMutableArray *)refinedGroups withTimeInterval:(CFGregorianUnits)gregorianUnit {
    do {
        ;
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCDataGroupBase
- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            SAFE_ARC_AUTORELEASE(dateFormatter);
            [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            result = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.earliestTime]];
        }
    } while (NO);
    return result;
}

- (NSUInteger)itemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (_allAssetItems) {
                result = [_allAssetItems count];
            }
        }
    } while (NO);
    return result;
}

#pragma mark - DCTimelineAssetsGroup - Private

@end
