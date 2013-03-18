//
//  DCTimelineALAssetsLibrary.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTimelineALAssetsLibrary.h"
#import "DCTimelineCommonConstants.h"
#import "DCTimelineAssetsGroup.h"
#import "DCTimelineInterval.h"
#import "DCALAssetItem.h"
//#import "ASImagePickerCommonDefine.h"
#import <CoreLocation/CoreLocation.h>

#define TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR (4)

@interface DCTimelineALAssetsLibrary () {
    NSMutableArray *_assetsTimelineGroups;
    DCTimelineAssetsGroup *_currentGroup;
    DCTimelineAssetsGroup *_preprocessorGroup;
    
    NSMutableArray *_unsortedAssetArray;
    NSMutableArray *_sortedAssetArray;
    
#ifdef DCTimeline_Method_Refine_Enable
#else
    NSTimeInterval _lastAssetTimeInterval;
#endif
    
//    NSMutableArray *_intervalArray;
}

- (void)initAssetsTimelineGroup;
- (void)clearTimelineGroupCache;
- (void)refineCurrentGroup;

#ifdef DCTimeline_Method_Refine_Enable
- (void)insertAsset:(ALAsset *)asset;
#else
- (void)insertAsset:(ALAsset *)asset atIndex:(NSUInteger)index andInterval:(DCTimelineInterval *)timelineInterval;
#endif

- (void)enumTimelineGroupAtIndex:(NSUInteger)groupIndex NotifyWithFrequency:(NSUInteger)frequency;
- (void)clearAssetArray;
- (void)grouping;

@end

@implementation DCTimelineALAssetsLibrary
#ifdef DCTimeline_Method_Refine_Enable
#else
@synthesize yesterday = _yesterday;
@synthesize yesterdayReady = _yesterdayReady;
@synthesize lastWeek = _lastWeek;
@synthesize lastWeekReady = _lastWeekReady;
@synthesize last100 = _last100;
@synthesize last100Ready = _last100Ready;
#endif

#pragma mark - DCTimelineALAssetsLibrary - DCDataLibraryBase
- (BOOL)connect:(NSDictionary *)params {
    BOOL result = NO;
    do {
        @synchronized(self) {
            result = [super connect:params];
            NSAssert(result, @"[super connect:params] error.");
            
        }
        result = YES;
    } while (NO);
    return result;
}

- (BOOL)disconnect {
    BOOL result = NO;
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_currentGroup);
            SAFE_ARC_SAFERELEASE(_preprocessorGroup);
            result = [super disconnect];
            NSAssert(result, @"[super disconnect] error.");
        }
        
        result = YES;
    } while (NO);
    return result;
}

- (void)initAssetsLib {
    do {
        @synchronized(self) {
            [super initAssetsLib];
            
            @synchronized(_unsortedAssetArray) {
                _unsortedAssetArray = [NSMutableArray array];
                SAFE_ARC_RETAIN(_unsortedAssetArray);
            }
            
            @synchronized(_sortedAssetArray) {
                _sortedAssetArray = [NSMutableArray array];
                SAFE_ARC_RETAIN(_sortedAssetArray);
            }
            
#ifdef DCTimeline_Method_Refine_Enable
#else
            @synchronized(_yesterday) {
                _yesterday = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                _yesterdayReady = NO;
            }
            @synchronized(_lastWeek) {
                _lastWeek = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                _lastWeekReady = NO;
            }
            @synchronized(_last100) {
                _last100 = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                _last100Ready = NO;
            }
            _lastAssetTimeInterval = 0;
#endif
            
//            @synchronized(_intervalArray) {
//                _intervalArray = [NSMutableArray array];
//                SAFE_ARC_RETAIN(_intervalArray);
//            }
        }
    } while (NO);
}

- (void)uninitAssetsLib {
    do {
        @synchronized(self) {
            [self clearTimelineGroupCache];
            SAFE_ARC_SAFERELEASE(_assetsTimelineGroups);
            [self clearAssetArray];
            
#ifdef DCTimeline_Method_Refine_Enable
#else
            @synchronized(_yesterday) {
                SAFE_ARC_SAFERELEASE(_yesterday);
                _yesterdayReady = NO;
            }
            @synchronized(_lastWeek) {
                SAFE_ARC_SAFERELEASE(_lastWeek);
                _lastWeekReady = NO;
            }
            @synchronized(_last100) {
                SAFE_ARC_SAFERELEASE(_last100);
                _last100Ready = NO;
            }
            _lastAssetTimeInterval = 0;
#endif
            
            @synchronized(_unsortedAssetArray) {
                SAFE_ARC_SAFERELEASE(_unsortedAssetArray);
            }
            @synchronized(_sortedAssetArray) {
                SAFE_ARC_SAFERELEASE(_sortedAssetArray);
            }
//            @synchronized(_intervalArray) {
//                SAFE_ARC_SAFERELEASE(_intervalArray);
//            }
            
            [super uninitAssetsLib];
        }
    } while (NO);
}

- (void)clearCache {
    do {
        @synchronized(self) {
            [super clearCache];            
        }
    } while (NO);
}

#pragma mark - DCTimelineALAssetsLibrary - DCTimelineDataLibrary
- (void)enumTimelineNotifyWithFrequency:(NSUInteger)frequency {
    [self enumTimelineGroupAtIndex:0 NotifyWithFrequency:frequency];
}

//- (void)enumTimelineAtIndexes:(NSIndexSet *)indexSet notifyWithFrequency:(NSUInteger)frequency {
//    SAFE_ARC_AUTORELEASE_POOL_START()
//    do {
//        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//            do {
//                if (_cancelEnum) {
//                    *stop = YES;
//                    _enumerating = NO;
//                    break;
//                }
//                
//                if (result != nil) {
//                } else {
//                    ;
//                }
//            } while (NO);
//        };
//        
//        @synchronized(self) {
//            if (!_assetsTimelineGroups) {
//                [self initAssetsTimelineGroup];
//            }
//            NSAssert(_assetsTimelineGroups, @"_assetsTimelineGroups == nil");
//            if (frequency == 0) {
//                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
//                break;
//            }
////
////            if (!_enumerating) {
////                [self clearCache];
////                
////                _frequency = frequency;
////                _enumCount = 0;
////                _cancelEnum = NO;
////                _enumerating = YES;
////                [_assetsTimelineGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:enumerator];
////            }
//        }
//    } while (NO);
//    SAFE_ARC_AUTORELEASE_POOL_END()
//}

#pragma mark - DCTimelineALAssetsLibrary - Private
- (void)initAssetsTimelineGroup {
    do {
        if (!_assetsTimelineGroups) {
            ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
            if (!assetsLibrary) {
                [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _assetsLibrary == nil"];
                break;
            }
            
            NSConditionLock *_lock = [[NSConditionLock alloc] initWithCondition:0];
            SAFE_ARC_AUTORELEASE(_lock);
            
            SAFE_ARC_AUTORELEASE_POOL_START()
            void (^enumerator)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
                do {
                    if (group != nil) {
                        if ([group numberOfAssets] > 0) {
                            NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                            [_assetsTimelineGroups addObject:group];
                            dc_debug_NSLog(@"Add group id: %@, count = %d", groupPersistentID, [group numberOfAssets]);
                        }
                    } else {
                        if ([_lock tryLockWhenCondition:0]) {
                            [_lock unlockWithCondition:1];
                        }
                    }
                } while (NO);
            };
            
            void (^failureReporter)(NSError *error) = ^(NSError *error) {
                if ([_lock tryLockWhenCondition:0]) {
                    [_lock unlockWithCondition:1];
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                SAFE_ARC_AUTORELEASE(alertView);
                [alertView show];
            };
            
            @synchronized(self) {
                [self clearTimelineGroupCache];
                
                _assetsTimelineGroups = [NSMutableArray array];
                SAFE_ARC_RETAIN(_assetsTimelineGroups);
                
                _cancelEnum = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                    NSAssert(assetsLibrary, @"_assetsLibrary == nil");
                    [assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupLibrary | ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream) usingBlock:enumerator failureBlock:failureReporter];
                });
                
            }
            [_lock lockWhenCondition:1];
            [_lock unlockWithCondition:0];
            SAFE_ARC_AUTORELEASE_POOL_END()
        }
        NSAssert(_assetsTimelineGroups, @"_assetsTimelineGroup == nil");
    } while (NO);
}

- (void)clearTimelineGroupCache {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
            
            if (_assetsTimelineGroups) {
                [_assetsTimelineGroups removeAllObjects];
            }
        }
    } while (NO);
}

- (void)refineCurrentGroup {
    do {
#ifdef DCTimeline_Method_Refine_Enable
        @synchronized(self) {
            NSMutableArray *refinedGroups = [NSMutableArray array];
            [_currentGroup refining:refinedGroups];
            if ([refinedGroups count] > 1) {
                [_allALAssetsGroups removeObjectForKey:[_currentGroup uniqueID]];
                [_allALAssetsGroupUIDs removeObject:[_currentGroup uniqueID]];
                SAFE_ARC_SAFERELEASE(_currentGroup);
                for (DCTimelineAssetsGroup *group in refinedGroups) {
                    [self insertGroup:group forUID:[group uniqueID]];
                    SAFE_ARC_SAFERELEASE(_currentGroup);
                    _currentGroup = group;
                    SAFE_ARC_RETAIN(_currentGroup);
                }
                [_currentGroup setGregorianUnitIntervalFineness:GUIF_1Month];
                if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                    _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                }
            }
            [refinedGroups removeAllObjects];
        }
#else
        @synchronized(_currentGroup) {
            NSMutableArray *refinedGroups = [NSMutableArray array];
            [_currentGroup refining:refinedGroups];
            if ([refinedGroups count] == 0) {
                ;
            } else {
                if ([refinedGroups count] < 2) {
                    NSAssert(NO, @"error");
                    break;
                } else {
                    @synchronized(_allALAssetsGroups) {
                        [_allALAssetsGroups removeObjectForKey:[_currentGroup uniqueID]];
                    }
                    
                    @synchronized(_allALAssetsGroupUIDs) {
                        [_allALAssetsGroupUIDs removeObject:[_currentGroup uniqueID]];
                    }
                    
                    SAFE_ARC_SAFERELEASE(_currentGroup);
                    
                    DCTimelineAssetsGroup *first = [refinedGroups objectAtIndex:0];
                    @synchronized(_preprocessorGroup) {
                        // processor for first
                        if (_preprocessorGroup) {
                            BOOL needMerge = NO;
                            
                            // [pG count] + [left count] < DCTimelineGroup_AssetsCountForLargeGroup?
                            if ([_preprocessorGroup itemsCountWithParam:nil] + [first itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForLargeGroup) {
                                CFGregorianDate leftDate = CFAbsoluteTimeGetGregorianDate([_preprocessorGroup.latestTime timeIntervalSinceReferenceDate], CFTimeZoneCopyDefault());
                                CFGregorianDate rightDate = CFAbsoluteTimeGetGregorianDate([_currentGroup.earliestTime timeIntervalSinceReferenceDate], CFTimeZoneCopyDefault());
                                
                                // Same date?
                                if (leftDate.year == rightDate.year && leftDate.month == rightDate.month && leftDate.day == rightDate.day) {
                                    needMerge = YES;
                                }
                            }
                            
                            if (needMerge) {
                                if ([first itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                    NSAssert(NO, @"error");
                                } else if ([first itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                                    NSAssert(NO, @"error");
                                } else {
                                    [_preprocessorGroup merge:first];
                                    [self insertGroup:_preprocessorGroup forUID:[_preprocessorGroup uniqueID]];
                                    
                                    SAFE_ARC_SAFERELEASE(_preprocessorGroup);
                                    first = nil;
                                }
                                
                            } else {
                                [self insertGroup:_preprocessorGroup forUID:[_preprocessorGroup uniqueID]];
                                SAFE_ARC_SAFERELEASE(_preprocessorGroup);
                                [self insertGroup:first forUID:[first uniqueID]];
                                first = nil;
                            }
                        } else {
                            [self insertGroup:first forUID:[first uniqueID]];
                            first = nil;
                        }
                        if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                            _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                        }
                    }
                                        
                    // processor for rest
                    NSUInteger count = [refinedGroups count];
                    for (NSUInteger idx = 1; idx < count; ++idx) {
                        DCTimelineAssetsGroup *group = [refinedGroups objectAtIndex:idx];
                        [self insertGroup:group forUID:[group uniqueID]];
                        if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                            _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                        }
                    }
                }
            }
            [refinedGroups removeAllObjects];
        }
#endif
    } while (NO);
}

- (void)clearAssetArray {
    do {
        @synchronized(_unsortedAssetArray) {
            if (_unsortedAssetArray) {
                [_unsortedAssetArray removeAllObjects];
            }
        }
        
        @synchronized(_sortedAssetArray) {
            if (_sortedAssetArray) {
                [_sortedAssetArray removeAllObjects];
            }
        }
        
//        @synchronized(_intervalArray) {
//            if (_intervalArray) {
//                [_intervalArray removeAllObjects];
//            }
//        }
    } while (NO);
}

#ifdef DCTimeline_Method_Refine_Enable
- (void)insertAsset:(ALAsset *)asset {
    do {
        if (!asset) {
            break;
        }
        @synchronized(self) {
            if (!_currentGroup) {
                _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                _currentGroup.notifyhFrequency = DCTimeline_Group_NotifyhFrequencyForAddItem;
                [_currentGroup insertDataItem:asset];
                [self insertGroup:_currentGroup forUID:[_currentGroup uniqueID]];
            } else {
                NSAssert(_currentGroup, @"_currentGroup == nil");
                // calc time interval
                NSTimeInterval currentAssetTimeInterval = [[asset valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                NSTimeInterval currentGroupTimeInterval = [_currentGroup.latestTime timeIntervalSinceReferenceDate];
                CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentAssetTimeInterval, currentGroupTimeInterval, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                NSComparisonResult compareResult = GregorianUnitCompare(diff, [_currentGroup currentTimeInterval]);
                if (compareResult == NSOrderedDescending) {  // Create a new group
                    if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                        _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                    }
                    SAFE_ARC_SAFERELEASE(_currentGroup);
                    _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                    _currentGroup.notifyhFrequency = DCTimeline_Group_NotifyhFrequencyForAddItem;
                    [_currentGroup insertDataItem:asset];
                    [self insertGroup:_currentGroup forUID:[_currentGroup uniqueID]];
                } else {  // Insert into current group
                    [_currentGroup insertDataItem:asset];
                    // Refine group
                    if ([_currentGroup itemsCountWithParam:nil] > DCTimeline_Group_CountForRefine) {
                        [self refineCurrentGroup];
                        NSAssert(_currentGroup, @"_currentGroup == nil");
                    }
                }
            }
        }
    } while (NO);
}
#else

- (void)insertAsset:(ALAsset *)asset atIndex:(NSUInteger)index andInterval:(DCTimelineInterval *)timelineInterval {
    do {
        if (_cancelEnum) {
            break;
        }
        @synchronized(_currentGroup) {
            if (!_currentGroup) {
                if (asset) {
                    _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                    _currentGroup.notifyhFrequency = DCTimeline_Group_NotifyhFrequencyForAddItem;
                    [_currentGroup insertDataItem:asset];
                }
            } else {
                NSAssert(_currentGroup, @"_currentGroup == nil");
                BOOL insert = NO;
                NSComparisonResult compareResult = NSOrderedDescending;
                if (asset) {
                    CFGregorianUnits difinedHours = CFGregorianUnits_DefinedHours;
                    CFGregorianUnits interval = timelineInterval.interval;
                    compareResult = GregorianUnitCompare(interval, difinedHours);
                }
                if (compareResult == NSOrderedDescending) {
                    insert = NO;
                } else {
                    NSComparisonResult compareResult1 = NSOrderedDescending;
                    CFGregorianUnits difinedHours = CFGregorianUnits_Hour(1);
                    CFGregorianUnits interval = timelineInterval.interval;
                    compareResult1 = GregorianUnitCompare(interval, difinedHours);
                    if (compareResult1 == NSOrderedDescending) {
                        ALAsset *asset1 = [[_currentGroup itemWithUID:[_currentGroup itemUIDAtIndex:([_currentGroup itemsCountWithParam:nil] - 1)]] origin];
                        CLLocation *loc1 = nil;
                        if ([asset1 respondsToSelector:@selector(valueForProperty:)]) {
                            loc1 = [asset1 valueForProperty:ALAssetPropertyLocation];
                        }
                        CLLocation *loc2 = nil;
                        if ([asset respondsToSelector:@selector(valueForProperty:)]) {
                            loc2 = [asset valueForProperty:ALAssetPropertyLocation];
                        }
                        double lat1 = LAT_LNG_ERROR;
                        double lng1 = LAT_LNG_ERROR;
                        if (loc1) {
                            lat1 = [loc1 coordinate].latitude;
                            lng1 = [loc1 coordinate].longitude;
                        }
                        double lat2 = LAT_LNG_ERROR;
                        double lng2 = LAT_LNG_ERROR;
                        if (loc2) {
                            lat2 = [loc2 coordinate].latitude;
                            lng2 = [loc2 coordinate].longitude;
                        }
                        
                        if (lat1 != LAT_LNG_ERROR && lat2 != LAT_LNG_ERROR && lng1 != LAT_LNG_ERROR && lng2 != LAT_LNG_ERROR) {
                            double distanceMeters = fastDistanceMeters(lat1, lat2, lng1, lng2);
                            NSLog(@"distanceMeters: %f", distanceMeters);
                            if (distanceMeters < KILOMETERS(100)) {
                                insert = YES;
                            }
                        } else {
                            insert = YES;
                        }
                    } else {
                        insert = YES;
                    }
                }
                
                if (insert == NO) {  // Preprocessor
                    @synchronized(_preprocessorGroup) {
                        if (_preprocessorGroup) {
                            BOOL needMerge = NO;
                            
                            // [pG count] + [cG count] < DCTimelineGroup_AssetsCountForLargeGroup?
                            if ([_preprocessorGroup itemsCountWithParam:nil] <  DCTimelineGroup_AssetsCountForTinyGroup && [_currentGroup itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                CFGregorianDate leftDate = CFAbsoluteTimeGetGregorianDate([_preprocessorGroup.latestTime timeIntervalSinceReferenceDate], CFTimeZoneCopyDefault());
                                CFGregorianDate rightDate = CFAbsoluteTimeGetGregorianDate([_currentGroup.earliestTime timeIntervalSinceReferenceDate], CFTimeZoneCopyDefault());
                                
                                // Same date?
                                if (leftDate.year == rightDate.year && leftDate.month == rightDate.month && leftDate.day == rightDate.day) {
                                    
                                    if ([_currentGroup itemsCountWithParam:nil] > 0) {
                                        ALAsset *asset1 = [[_preprocessorGroup itemWithUID:[_preprocessorGroup itemUIDAtIndex:([_preprocessorGroup itemsCountWithParam:nil] - 1)]] origin];
                                        ALAsset *asset2 = [[_currentGroup itemWithUID:[_currentGroup itemUIDAtIndex:(0)]] origin];
                                        CLLocation *loc1 = nil;
                                        if ([asset1 respondsToSelector:@selector(valueForProperty:)]) {
                                            loc1 = [asset1 valueForProperty:ALAssetPropertyLocation];
                                        }
                                        CLLocation *loc2 = nil;
                                        if ([asset2 respondsToSelector:@selector(valueForProperty:)]) {
                                            loc2 = [asset2 valueForProperty:ALAssetPropertyLocation];
                                        }
                                        double lat1 = LAT_LNG_ERROR;
                                        double lng1 = LAT_LNG_ERROR;
                                        if (loc1) {
                                            lat1 = [loc1 coordinate].latitude;
                                            lng1 = [loc1 coordinate].longitude;
                                        }
                                        double lat2 = LAT_LNG_ERROR;
                                        double lng2 = LAT_LNG_ERROR;
                                        if (loc2) {
                                            lat2 = [loc2 coordinate].latitude;
                                            lng2 = [loc2 coordinate].longitude;
                                        }
                                        if (lat1 != LAT_LNG_ERROR && lat2 != LAT_LNG_ERROR && lng1 != LAT_LNG_ERROR && lng2 != LAT_LNG_ERROR) {
                                            double distanceMeters = fastDistanceMeters(lat1, lat2, lng1, lng2);
                                            NSLog(@"distanceMeters: %f", distanceMeters);
                                            if (distanceMeters < KILOMETERS(100)) {
                                                needMerge = YES;
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            if (needMerge) {
                                if ([_currentGroup itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                    [_preprocessorGroup merge:_currentGroup];
                                } else if ([_currentGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                                    NSAssert(NO, @"error");
                                } else {
                                    [_preprocessorGroup merge:_currentGroup];
                                    [self insertGroup:_preprocessorGroup forUID:[_preprocessorGroup uniqueID]];
                                    SAFE_ARC_SAFERELEASE(_preprocessorGroup);
                                    if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                                        _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                                    }
                                }
                                
                            } else {
                                [self insertGroup:_preprocessorGroup forUID:[_preprocessorGroup uniqueID]];
                                SAFE_ARC_SAFERELEASE(_preprocessorGroup);
                                if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                                    _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                                }

                                if ([_currentGroup itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                    _preprocessorGroup = _currentGroup;
                                    SAFE_ARC_RETAIN(_preprocessorGroup);
                                } else if ([_currentGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                                    // refine and redefine current group
                                    [self refineCurrentGroup];
                                } else {
                                    [self insertGroup:_currentGroup forUID:[_currentGroup uniqueID]];
                                    SAFE_ARC_SAFERELEASE(_currentGroup);
                                    if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                                        _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                                    }
                                }
                                
                            }
                            
                            if ([_currentGroup itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                SAFE_ARC_SAFERELEASE(_currentGroup);
                            } else if ([_currentGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                                SAFE_ARC_SAFERELEASE(_currentGroup);
                            } else {
                                SAFE_ARC_SAFERELEASE(_currentGroup);
                            }
                        } else {
                            if ([_currentGroup itemsCountWithParam:nil] < DCTimelineGroup_AssetsCountForTinyGroup) {
                                _preprocessorGroup = _currentGroup;
                                SAFE_ARC_RETAIN(_preprocessorGroup);
                                SAFE_ARC_SAFERELEASE(_currentGroup);
                            } else if ([_currentGroup itemsCountWithParam:nil] > DCTimelineGroup_AssetsCountForLargeGroup) {
                                // refine and redefine current group
                                [self refineCurrentGroup];
                            } else {
                                [self insertGroup:_currentGroup forUID:[_currentGroup uniqueID]];
                                SAFE_ARC_SAFERELEASE(_currentGroup);
                                if ([_allALAssetsGroupUIDs count] % _frequency == 0) {
                                    _frequency *= TIMELINEALASSETSLIBRARY_FREQUENCY_FACTOR;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                                }
                            }
                        }
                    }
                    
                    if (asset) {
                        _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                        _currentGroup.notifyhFrequency = DCTimeline_Group_NotifyhFrequencyForAddItem;
                        [_currentGroup insertDataItem:asset];
                    }
                } else {
                    // Insert into current group
                    if (asset) {
                        [_currentGroup insertDataItem:asset];
                    }
                }
            }
        }
    } while (NO);
}
#endif
    

- (void)enumTimelineGroupAtIndex:(NSUInteger)groupIndex NotifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        __block NSUInteger nextGroupIndex = groupIndex;
        __block float screenWidth = [[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale];
        __block float screenHeight = [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale];
        __block BOOL needRemoveScreenShot = NO;
        ++nextGroupIndex;
        
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            SAFE_ARC_AUTORELEASE_POOL_START()
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    long width = 0;
                    long height = 0;
                    if (needRemoveScreenShot) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        if (representation) {
                            NSDictionary *metadataDict = [representation metadata];
                            if (metadataDict) {
                                width = [[metadataDict valueForKey:kDCALAssetItem_MetaData_PixelWidth] intValue];
                                height = [[metadataDict valueForKey:kDCALAssetItem_MetaData_PixelHeight] intValue];
                            }
                        }
                    }
                    
                    if (width != screenWidth || height != screenHeight) {
                        @synchronized(_unsortedAssetArray) {
                            [_unsortedAssetArray addObject:result];
                        }
                    } else {
                        ;
                    }
                
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                        [self enumTimelineGroupAtIndex:nextGroupIndex NotifyWithFrequency:_frequency];
                    });
                }
            } while (NO);
            SAFE_ARC_AUTORELEASE_POOL_END()
        };
        
        if (!_enumerating || (_enumerating && groupIndex != 0)) {
            if (_cancelEnum) {
                _enumerating = NO;
                break;
            }
            
            _enumerating = YES;
            
            if (groupIndex == 0) {
                if (!_assetsTimelineGroups) {
                    [self initAssetsTimelineGroup];
                }
                NSAssert(_assetsTimelineGroups, @"_assetsTimelineGroups == nil");
                
                [self clearAssetArray];
                
                [self clearCache];
            }
            
            if (frequency == 0) {
                _enumerating = NO;
                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (groupIndex > [_assetsTimelineGroups count]) {
                _enumerating = NO;
                break;
            } else if (groupIndex == [_assetsTimelineGroups count]) {
                [self grouping];
                break;
            }
            
            @synchronized(self) {
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
//                needRemoveScreenShot = ([[[_assetsTimelineGroups objectAtIndex:groupIndex] valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                    [[_assetsTimelineGroups objectAtIndex:groupIndex] setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [[_assetsTimelineGroups objectAtIndex:groupIndex] enumerateAssetsUsingBlock:enumerator];
                });
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (void)grouping {
    do {
        @synchronized(_sortedAssetArray) {
            if (_sortedAssetArray) {
                [_sortedAssetArray removeAllObjects];
                SAFE_ARC_SAFERELEASE(_sortedAssetArray);
            }
            
            @synchronized(_unsortedAssetArray) {
                _sortedAssetArray = [NSMutableArray arrayWithArray:_unsortedAssetArray];
            }
            SAFE_ARC_RETAIN(_sortedAssetArray);
            
            [_sortedAssetArray sortUsingComparator:^(id obj1, id obj2) {
                
                NSDate *leftDate = [obj1 valueForProperty:ALAssetPropertyDate];
                NSDate *rightDate = [obj2 valueForProperty:ALAssetPropertyDate];
                return [rightDate compare:leftDate];
            }];
            
#ifdef DCTimeline_Method_Refine_Enable
#else
//            if (_intervalArray) {
//                [_intervalArray removeAllObjects];
//                SAFE_ARC_SAFERELEASE(_intervalArray);
//            }
//            _intervalArray = [NSMutableArray array];
//            SAFE_ARC_RETAIN(_intervalArray);
            NSUInteger count = [_sortedAssetArray count];
#endif
            NSUInteger index = 0;
            for (ALAsset *asset in _sortedAssetArray) {
#ifdef DCTimeline_Method_Refine_Enable
#else
                if (_cancelEnum) {
                    break;
                }
                DCTimelineInterval *interval = nil;
                NSTimeInterval currentAssetTimeInterval = [[[_sortedAssetArray objectAtIndex:index] valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                if (index == 0) {
                    _lastAssetTimeInterval = currentAssetTimeInterval;
                } else if (index > 0 && index < count) {
                    NSTimeInterval left = [[[_sortedAssetArray objectAtIndex:index - 1] valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                    NSTimeInterval right = currentAssetTimeInterval;
                    interval = [[DCTimelineInterval alloc] init];
                    SAFE_ARC_AUTORELEASE(interval);
                    interval.leftIndex = index - 1;
                    interval.rightIndex = index;
                    interval.interval = CFAbsoluteTimeGetDifferenceAsGregorianUnits(left, right, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
//                    [_intervalArray addObject:interval];
                }
#endif
                dc_debug_NSLog(@"asset date: %@", [asset valueForProperty:ALAssetPropertyDate]);
#ifdef DCTimeline_Method_Refine_Enable
                [self insertAsset:asset];
#else
                [self insertAsset:asset atIndex:index andInterval:interval];
                if (_cancelEnum) {
                    break;
                }
                // action for last100 group
                if (index < 100) {
                    @synchronized(_last100) {
                        if ([_last100 isKindOfClass:[DCTimelineAssetsGroup class]]) {
                            DCTimelineAssetsGroup *tmp = (DCTimelineAssetsGroup *)_last100;
                            [tmp insertDataItem:asset];
                        }
                    }
                    if (index == 99) {
                        if (!self.last100Ready) {
                            _last100Ready = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_LAST100_READY object:nil];
                        }
                    }
                }
                
                NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
                CFGregorianUnits gregorianUnitsInterval = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentTimeInterval, currentAssetTimeInterval, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                if (gregorianUnitsInterval.years < 0 || gregorianUnitsInterval.months < 0 || gregorianUnitsInterval.days < 0 || gregorianUnitsInterval.hours < 0 || gregorianUnitsInterval.minutes < 0 || gregorianUnitsInterval.seconds < 0.0f) {
                    ;
                } else {
                    // action for yesterday group
                    if (gregorianUnitsInterval.years == 0 && gregorianUnitsInterval.months == 0 && gregorianUnitsInterval.days == 0) {
                        @synchronized(_yesterday) {
                            if ([_yesterday isKindOfClass:[DCTimelineAssetsGroup class]]) {
                                DCTimelineAssetsGroup *tmp = (DCTimelineAssetsGroup *)_yesterday;
                                [tmp insertDataItem:asset];
                            }
                        }
                    } else if (gregorianUnitsInterval.years > 0 || gregorianUnitsInterval.months > 0 || gregorianUnitsInterval.days > 0) {
                        if (!self.yesterdayReady) {
                            _yesterdayReady = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_YESTERDAY_READY object:nil];
                        }
                    }
                    // action for lastWeek group
                    if (gregorianUnitsInterval.years == 0 && gregorianUnitsInterval.months == 0 && gregorianUnitsInterval.days < 7) {
                        @synchronized(_lastWeek) {
                            if ([_lastWeek isKindOfClass:[DCTimelineAssetsGroup class]]) {
                                DCTimelineAssetsGroup *tmp = (DCTimelineAssetsGroup *)_lastWeek;
                                [tmp insertDataItem:asset];
                            }
                        }
                    } else if (gregorianUnitsInterval.years > 0 || gregorianUnitsInterval.months > 0 || gregorianUnitsInterval.days >= 7) {
                        if (!self.lastWeekReady) {
                            _lastWeekReady = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_LASTWEEK_READY object:nil];
                        }
                    }
                }
#endif
                ++index;
            }
#ifdef DCTimeline_Method_Refine_Enable
#else
            if (!_cancelEnum) {
                [self insertAsset:nil atIndex:index andInterval:nil];
                if (_preprocessorGroup) {
                    [self insertGroup:_preprocessorGroup forUID:[_preprocessorGroup uniqueID]];
                    SAFE_ARC_SAFERELEASE(_preprocessorGroup);
                }
                if (_currentGroup) {
                    [self insertGroup:_currentGroup forUID:[_currentGroup uniqueID]];
                    SAFE_ARC_SAFERELEASE(_currentGroup);
                }
            }
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ENUM_END object:self];

            if (!self.last100Ready) {
                _last100Ready = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_LAST100_READY object:nil];
            }
            if (!self.yesterdayReady) {
                _yesterdayReady = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_YESTERDAY_READY object:nil];
            }
            if (!self.lastWeekReady) {
                _lastWeekReady = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATATIMELINEGROUP_LASTWEEK_READY object:nil];
            }
        }
    } while (NO);
    _enumerating = NO;
}

#pragma mark - DCTimelineALAssetsLibrary - DCAssetsLibUser
- (void)nofityAssetsLibStable {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
        }
        [super nofityAssetsLibStable];
        NSUInteger frequency = _frequency > 0 ? _frequency : 16;
        [self enumTimelineNotifyWithFrequency:frequency];
    } while (NO);
}

@end
