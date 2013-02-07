//
//  DCTimelineAssetsGroup.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCTimelineAssetsGroup.h"
#import "DCALAssetItem.h"
#import "DCTimelineCommonConstants.h"

@interface DCTimelineAssetsGroup () {
}

@end

@implementation DCTimelineAssetsGroup

@synthesize earliestTime = _earliestTime;
@synthesize latestTime = _latestTime;
@synthesize currentTimeInterval = _currentTimeInterval;
@synthesize intervalFineness = _intervalFineness;
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
                NSUInteger count = [_allAssetUIDs count];
                if (count == 0) {
                    _earliestTime = [asset valueForProperty:ALAssetPropertyDate];
                }
                
                _latestTime = [asset valueForProperty:ALAssetPropertyDate];
                
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                NSURL *url = [representation url];
                NSString *assetURLStr = [url absoluteString];
                
                DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:asset];
                [_allAssetItems setObject:item forKey:assetURLStr];
                NSUInteger indexForAsset = [_allAssetUIDs count];
                [_allAssetUIDs insertObject:assetURLStr atIndex:indexForAsset];
                count = [_allAssetUIDs count];
                if (count == (count / self.notifyhFrequency) * self.notifyhFrequency) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                }
            }
        }
    } while (NO);
}

- (id)initWithGregorianUnitIntervalFineness:(GregorianUnitIntervalFineness)intervalFineness {
    @synchronized(self) {
        self = [super init];
        if (self) {
            ZeroCFGregorianUnits(_currentTimeInterval);
            _intervalFineness = intervalFineness;
            _currentTimeInterval = CFGregorianUnits_IntervalArray[_intervalFineness];
            @synchronized(self) {
                if (!_allAssetItems) {
                    _allAssetItems = [[NSMutableDictionary alloc] init];
                }
                
                if (!_allAssetUIDs) {
                    _allAssetUIDs = [[NSMutableArray alloc] init];
                }
            }
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _intervalFineness = GUIF_Unknown;
            ZeroCFGregorianUnits(_currentTimeInterval);
            SAFE_ARC_SAFERELEASE(_earliestTime);
            SAFE_ARC_SAFERELEASE(_latestTime);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCTimelineDataGroup
- (void)refining:(NSMutableArray *)refinedGroups {
    do {
        @synchronized(self) {
            if (!refinedGroups) {
                break;
            }
            if (self.intervalFineness < GUIF_Count - 1) {
                ++_intervalFineness;
                _currentTimeInterval = CFGregorianUnits_IntervalArray[self.intervalFineness];
                NSArray *items = [_allAssetItems allValues];
                DCTimelineAssetsGroup *newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                SAFE_ARC_AUTORELEASE(newGroup);
                for (DCALAssetItem *item in items) {
                    if ([newGroup itemsCountWithParam:nil] == 0) {
                        [newGroup insertDataItem:[item origin]];
                        [refinedGroups addObject:newGroup];
                    } else {
                        NSTimeInterval currentAssetTimeInterval = [[item valueForProperty:kDATAITEMPROPERTY_PROPERTYDATE withOptions:nil] timeIntervalSinceReferenceDate];
                        NSTimeInterval currentGroupTimeInterval = [self.earliestTime timeIntervalSinceReferenceDate];
                        CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentAssetTimeInterval, currentGroupTimeInterval, NULL, kCFGregorianAllUnits);
                        int compareResult = GregorianUnitCompare(diff, self.currentTimeInterval);
                        if (compareResult > 0) {
                            // Release old group
                            SAFE_ARC_SAFERELEASE(newGroup);
                            // Create a new group
                            newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                            SAFE_ARC_AUTORELEASE(newGroup);
                            
                        } else {  
                            ;
                        }
                        // Insert into current group
                        [newGroup insertDataItem:[item origin]];
                    }
                }
            }
        }
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
