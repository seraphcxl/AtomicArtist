//
//  DCTimelineAssetsGroup.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCTimelineAssetsGroup.h"

@interface DCTimelineAssetsGroup () {
}

@end

@implementation DCTimelineAssetsGroup

@synthesize earliestTime = _earliestTime;
@synthesize latestTime = _latestTime;

- (void)insertDataItem:(DCALAssetItem *)assetItem {
    do {
        ;
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCTimelineDataGroup
- (void)refining:(NSArray *)refinedGroups withTimeInterval:(CFTimeInterval)timeInterval {
    do {
        ;
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCDataGroupBase
- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
            ;
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
