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

@interface DCTimelineALAssetsLibrary () {
    ALAssetsGroup *_assetsTimelineGroup;
    DCTimelineAssetsGroup *_currentGroup;
}

- (void)initAssetsTimelineGroup;
- (void)clearTimelineGroupCache;
- (void)refineCurrentGroup;

@end

@implementation DCTimelineALAssetsLibrary

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
            result = [super disconnect];
            NSAssert(result, @"[super disconnect] error.");
        }
        
        result = YES;
    } while (NO);
    return result;
}

- (void)clearCache {
    do {
        @synchronized(self) {
            [super clearCache];
            
            SAFE_ARC_SAFERELEASE(_assetsTimelineGroup);
        }
    } while (NO);
}

#pragma mark - DCTimelineALAssetsLibrary - DCTimelineDataLibrary
- (void)enumTimelineNotifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    if (!_currentGroup) {  // First group
                        _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                        [_currentGroup insertDataItem:result];
                        NSUInteger index = [_allALAssetsGroupUIDs count];
                        NSString *uid = [_currentGroup uniqueID];
                        [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                        [_allALAssetsGroups setObject:_currentGroup forKey:uid];
                    } else {
                        NSAssert(_currentGroup, @"_currentGroup == nil");
                        // calc time interval
                        NSTimeInterval currentAssetTimeInterval = [[result valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                        NSTimeInterval currentGroupTimeInterval = [[_currentGroup earliestTime] timeIntervalSinceReferenceDate];
                        CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentAssetTimeInterval, currentGroupTimeInterval, NULL, kCFGregorianAllUnits);
                        int compareResult = GregorianUnitCompare(diff, [_currentGroup currentTimeInterval]);
                        if (compareResult > 0) {  // Create a new group
                            SAFE_ARC_SAFERELEASE(_currentGroup);
                            _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                            [_currentGroup insertDataItem:result];
                            NSUInteger index = [_allALAssetsGroupUIDs count];
                            NSString *uid = [_currentGroup uniqueID];
                            [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                            [_allALAssetsGroups setObject:_currentGroup forKey:uid];
                        } else {  // Insert into current group
                            [_currentGroup insertDataItem:result];
                            // Refine group
                            if ([_currentGroup itemsCountWithParam:nil] > DCTimelineDataGroup_CountForRefine) {
                                [self refineCurrentGroup];
                                NSAssert(_currentGroup, @"_currentGroup == nil");
                            }
                        }
                    }
                } else {
                    ;
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
                [self initAssetsTimelineGroup];
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
            if (frequency == 0) {
                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                [_assetsTimelineGroup enumerateAssetsUsingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (void)enumTimelineAtIndexes:(NSIndexSet *)indexSet notifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    if (!_currentGroup) {  // First group
                        _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                        [_currentGroup insertDataItem:result];
                        NSUInteger index = [_allALAssetsGroupUIDs count];
                        NSString *uid = [_currentGroup uniqueID];
                        [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                        [_allALAssetsGroups setObject:_currentGroup forKey:uid];
                    } else {
                        NSAssert(_currentGroup, @"_currentGroup == nil");
                        // calc time interval
                        NSTimeInterval currentAssetTimeInterval = [[result valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                        NSTimeInterval currentGroupTimeInterval = [[_currentGroup earliestTime] timeIntervalSinceReferenceDate];
                        CFGregorianUnits diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits(currentAssetTimeInterval, currentGroupTimeInterval, NULL, kCFGregorianAllUnits);
                        int compareResult = GregorianUnitCompare(diff, [_currentGroup currentTimeInterval]);
                        if (compareResult > 0) {  // Create a new group
                            SAFE_ARC_SAFERELEASE(_currentGroup);
                            _currentGroup = [[DCTimelineAssetsGroup alloc] initWithGregorianUnitIntervalFineness:GUIF_1Month];
                            [_currentGroup insertDataItem:result];
                            NSUInteger index = [_allALAssetsGroupUIDs count];
                            NSString *uid = [_currentGroup uniqueID];
                            [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                            [_allALAssetsGroups setObject:_currentGroup forKey:uid];
                        } else {  // Insert into current group
                            [_currentGroup insertDataItem:result];
                            // Refine group
                            if ([_currentGroup itemsCountWithParam:nil] > DCTimelineDataGroup_CountForRefine) {
                                [self refineCurrentGroup];
                                NSAssert(_currentGroup, @"_currentGroup == nil");
                            }
                        }
                    }
                } else {
                    ;
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
                [self initAssetsTimelineGroup];
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
            if (frequency == 0) {
                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                [_assetsTimelineGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

#pragma mark - DCTimelineALAssetsLibrary - Private
- (void)initAssetsTimelineGroup {
    do {
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
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
                        if (_cancelEnum) {
                            *stop = _cancelEnum;
                            _enumerating = NO;
                            break;
                        }
                        
                        if (group != nil && [group numberOfAssets] > 0) {
                            NSAssert(!_assetsTimelineGroup, @"_assetsTimelineGroup != nil");
                            @synchronized(self) {
                                if (_cancelEnum) {
                                    *stop = _cancelEnum;
                                    _enumerating = NO;
                                    break;
                                }
                                _assetsTimelineGroup = group;
                                SAFE_ARC_RETAIN(_assetsTimelineGroup);
                            }
                            dc_debug_NSLog(@"Add timeline group count = %d", [group numberOfAssets]);
                        } else {
                            ;
                        }
                    } while (NO);
                    
                    if ([_lock tryLockWhenCondition:0]) {
                        [_lock unlockWithCondition:1];
                    }
                };
                
                void (^failureReporter)(NSError *error) = ^(NSError *error) {
                    if ([_lock tryLockWhenCondition:0]) {
                        [_lock unlockWithCondition:1];
                    }
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    SAFE_ARC_AUTORELEASE(alertView);
                    [alertView show];
                };
                
                if (!_enumerating) {
                    [self clearTimelineGroupCache];
                    
                    _cancelEnum = NO;
                    _enumerating = YES;
                    NSAssert(assetsLibrary, @"_assetsLibrary == nil");
                    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:enumerator failureBlock:failureReporter];
                    [_lock lockWhenCondition:1];
                    [_lock unlockWithCondition:0];
                }
                SAFE_ARC_AUTORELEASE_POOL_END()
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
        }
    } while (NO);
}

- (void)clearTimelineGroupCache {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
            
            SAFE_ARC_SAFERELEASE(_assetsTimelineGroup);
        }
    } while (NO);
}

- (void)refineCurrentGroup {
    do {
        @synchronized(self) {
            NSMutableArray *refinedGroups = [NSMutableArray array];
            [_currentGroup refining:refinedGroups];
            if ([refinedGroups count] > 1) {
                [_allALAssetsGroups removeObjectForKey:[_currentGroup uniqueID]];
                [_allALAssetsGroupUIDs removeObject:[_currentGroup uniqueID]];
                SAFE_ARC_SAFERELEASE(_currentGroup);
                for (DCTimelineAssetsGroup *group in refinedGroups) {
                    NSUInteger index = [_allALAssetsGroupUIDs count];
                    NSString *uid = [group uniqueID];
                    [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                    [_allALAssetsGroups setObject:group forKey:uid];
                    _currentGroup = group;
                    SAFE_ARC_RETAIN(_currentGroup);
                }
            }
        }
    } while (NO);
}

@end
