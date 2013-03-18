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
#import "DCTimelineInterval.h"

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
                    if ([asset respondsToSelector:@selector(valueForProperty:)]) {
                        _latestTime = [asset valueForProperty:ALAssetPropertyDate];
                    }
                    SAFE_ARC_RETAIN(_latestTime);
                }
                
                SAFE_ARC_SAFERELEASE(_earliestTime);
                if ([asset respondsToSelector:@selector(valueForProperty:)]) {
                    _earliestTime = [asset valueForProperty:ALAssetPropertyDate];
                }
                SAFE_ARC_RETAIN(_earliestTime);
                
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                NSURL *url = [representation url];
                NSString *assetURLStr = [url absoluteString];
                
                DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:asset];
                [self insertItem:item forUID:assetURLStr];
                SAFE_ARC_AUTORELEASE(item);
                
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
                    _allAssetItems = [NSMutableDictionary dictionary];
                    SAFE_ARC_RETAIN(_allAssetItems);
                }
                
                if (!_allAssetUIDs) {
                    _allAssetUIDs = [NSMutableArray array];
                    SAFE_ARC_RETAIN(_allAssetUIDs);
                }
                
                self.notifyhFrequency = DCTimeline_Group_NotifyhFrequencyForAddItem;
            }
        }
        return self;
    }
}

- (void)setGregorianUnitIntervalFineness:(GregorianUnitIntervalFineness)intervalFineness {
    do {
        @synchronized(self) {
            ZeroCFGregorianUnits(_currentTimeInterval);
            _intervalFineness = intervalFineness;
            _currentTimeInterval = CFGregorianUnits_IntervalArray[_intervalFineness];
        }
    } while (NO);
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

- (void)merge:(DCTimelineAssetsGroup *)otherGroup {
    do {
        if (!otherGroup) {
            break;
        }
        @synchronized(self) {
            NSUInteger itemCount = [otherGroup itemsCountWithParam:nil];
            for (NSUInteger idx = 0; idx < itemCount; ++idx) {
                [self insertDataItem:[[otherGroup itemWithUID:[otherGroup itemUIDAtIndex:idx]] origin]];
            }
        }
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCTimelineDataGroup
- (void)refining:(NSMutableArray *)refinedGroups {
    do {
#ifdef DCTimeline_Method_Refine_Enable
        @synchronized(self) {
            if (!refinedGroups) {
                break;
            }
            if (self.intervalFineness < GUIF_Count - 1) {
                ++_intervalFineness;
                _currentTimeInterval = CFGregorianUnits_IntervalArray[self.intervalFineness];
                DCTimelineAssetsGroup *newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                newGroup.notifyhFrequency = self.notifyhFrequency;
                [refinedGroups addObject:newGroup];
                SAFE_ARC_AUTORELEASE(newGroup);
                for (NSString *itemUID in _allAssetUIDs) {
                    DCALAssetItem *item = [_allAssetItems objectForKey:itemUID];
                    if ([newGroup itemsCountWithParam:nil] == 0) {
                        [newGroup insertDataItem:[item origin]];
                    } else {
                        BOOL needCreateNewGroup = NO;
                        NSTimeInterval currentAssetTimeInterval = [[[item origin] valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                        NSTimeInterval currentGroupTimeInterval = [newGroup.latestTime timeIntervalSinceReferenceDate];
                        CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentAssetTimeInterval, currentGroupTimeInterval, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                        NSComparisonResult compareResult = GregorianUnitCompare(diff, newGroup.currentTimeInterval);
                        if (compareResult == NSOrderedDescending) {
                            needCreateNewGroup = YES;
                        } else {
                            if (newGroup.intervalFineness == GUIF_1Day) {
                                CFGregorianDate currentAssetGregorianDate = CFAbsoluteTimeGetGregorianDate(currentAssetTimeInterval, CFTimeZoneCopyDefault());
                                CFGregorianDate currentGroupGregorianDate = CFAbsoluteTimeGetGregorianDate(currentGroupTimeInterval, CFTimeZoneCopyDefault());
                                if (currentAssetGregorianDate.day != currentGroupGregorianDate.day) {
                                    needCreateNewGroup = YES;
                                }
                            }
                        }
                        
                        if (needCreateNewGroup) {
                            // Create a new group
                            newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                            newGroup.notifyhFrequency = self.notifyhFrequency;
                            [refinedGroups addObject:newGroup];
                            SAFE_ARC_AUTORELEASE(newGroup);
                        }
                        // Insert into current group
                        [newGroup insertDataItem:[item origin]];
                    }
                }
            }
        }
#else
        @synchronized(self) {
            if (!refinedGroups) {
                break;
            }
            
            NSMutableArray *intervalArray = [NSMutableArray array];
            NSUInteger count = [_allAssetUIDs count];
            for (NSUInteger idx = 0; idx < count - 1; ++idx) {
                NSTimeInterval left = [[[[_allAssetItems objectForKey:[_allAssetUIDs objectAtIndex:idx]] origin]  valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                NSTimeInterval right = [[[[_allAssetItems objectForKey:[_allAssetUIDs objectAtIndex:idx + 1]] origin]  valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                DCTimelineInterval *interval = [[DCTimelineInterval alloc] init];
                SAFE_ARC_AUTORELEASE(interval);
                interval.leftIndex = idx;
                interval.rightIndex = idx + 1;
                interval.interval = CFAbsoluteTimeGetDifferenceAsGregorianUnits(left, right, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                [intervalArray addObject:interval];
            }
            [intervalArray sortUsingComparator:^(id obj1, id obj2) {
                return GregorianUnitCompare([obj2 interval], [obj1 interval]);
            }];
            DCTimelineInterval *selectedInterval = nil;
            for (DCTimelineInterval *interval in intervalArray) {
                if (interval.leftIndex >= (DCTimelineGroup_AssetsCountForTinyGroup - 1) && interval.rightIndex <= count - (DCTimelineGroup_AssetsCountForTinyGroup - 1)) {
                    selectedInterval = interval;
                    break;
                }
            }
            if (selectedInterval) {
                dc_debug_NSLog(@"refining selected interval:%d, %d, %d, %d, %d, %f", (int)selectedInterval.interval.years, (int)selectedInterval.interval.months, (int)selectedInterval.interval.days, (int)selectedInterval.interval.hours, (int)selectedInterval.interval.minutes, selectedInterval.interval.seconds);
                DCTimelineAssetsGroup *newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                newGroup.notifyhFrequency = self.notifyhFrequency;
                SAFE_ARC_AUTORELEASE(newGroup);
                
                NSUInteger idx = 0;
                for (NSString *itemUID in _allAssetUIDs) {
                    DCALAssetItem *item = [_allAssetItems objectForKey:itemUID];
                    [newGroup insertDataItem:[item origin]];
                    if (idx == selectedInterval.leftIndex) {
                        if ([newGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                            [newGroup refining:refinedGroups];
                        } else {
                            [refinedGroups addObject:newGroup];
                        }
                        newGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:self.intervalFineness];
                        newGroup.notifyhFrequency = self.notifyhFrequency;
                        
                        SAFE_ARC_AUTORELEASE(newGroup);
                    }
                    ++idx;
                }
                if ([newGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                    [newGroup refining:refinedGroups];
                } else {
                    [refinedGroups addObject:newGroup];
                }
            }
        }
#endif
    } while (NO);
}

#pragma mark - DCTimelineAssetsGroup - DCDataGroupBase
- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            SAFE_ARC_AUTORELEASE(dateFormatter);
            
            [dateFormatter setTimeStyle:kCFDateFormatterFullStyle];
            [dateFormatter setDateStyle:kCFDateFormatterFullStyle];
            
            result = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.latestTime]];
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

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        @synchronized(self) {
            if ([property isEqualToString:kDATAGROUPPROPERTY_GROUPNAME]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                SAFE_ARC_AUTORELEASE(dateFormatter);
                
                NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
                NSTimeInterval currentGroupTimeInterval = [self.latestTime timeIntervalSinceReferenceDate];
                CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentTimeInterval, currentGroupTimeInterval, NULL, kCFGregorianAllUnits);
                
                if (ABS(diff.years) == 0 && ABS(diff.months) == 0 && ABS(diff.days) == 0) {
                    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                    
                    result = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.latestTime]];
                } else {
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                    
                    NSTimeInterval last = [self.latestTime timeIntervalSinceReferenceDate];
                    NSTimeInterval earliest = [self.earliestTime timeIntervalSinceReferenceDate];
                    CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(last, earliest, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                    
                    if (ABS(diff.years) == 0 && ABS(diff.months) == 0 && ABS(diff.days) == 0) {
                        result = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.latestTime]];
                    } else {
                        result = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.latestTime], [dateFormatter stringFromDate:self.earliestTime]];
                    }
                }
                
            } else if ([property isEqualToString:kDATAGROUPPROPERTY_POSTERIMAGE]) {
                id<DCDataItem> item = [self itemWithUID:[self itemUIDAtIndex:0]];
                if (item) {
                    result = [item valueForProperty:kDATAITEMPROPERTY_THUMBNAIL withOptions:nil];
                }
            } else {
                [NSException raise:@"DCALAssetsGroup error" format:@"Reason: unknown property"];
            }
        }
    } while (NO);
    return result;
}

#pragma mark - DCTimelineAssetsGroup - Private

@end
