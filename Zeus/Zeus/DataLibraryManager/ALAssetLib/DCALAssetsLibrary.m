//
//  DCALAssetsLibrary.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCALAssetsLibrary.h"
#import "DCALAssetsGroup.h"

#define ALASSETSLIBRARY_FREQUENCY_FACTOR (4)

@interface DCALAssetsLibrary () {
}

@end

@implementation DCALAssetsLibrary

//- (void)clearTimelineGroupCache {
//    do {
//        @synchronized(self) {
//            _cancelEnum = YES;
//            
//            SAFE_ARC_SAFERELEASE(_assetsTimelineGroup);
//        }
//    } while (NO);
//}

#pragma mark - DCALAssetsLibrary - DCDataLibrary
- (void)enumGroups:(id)groupParam notifyWithFrequency:(NSUInteger)frequency {
    do {
        ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
        if (!assetsLibrary) {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _assetsLibrary == nil"];
            break;
        }
        if (!_allALAssetsGroupPersistentIDs || !_allALAssetsGroups) {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _allALAssetsGroupPersistentIDs == nil || _allALAssetsGroups == nil"];
            break;
        }
        if (frequency == 0) {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
            break;
        }
        
        SAFE_ARC_AUTORELEASE_POOL_START()
        void (^enumerator)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = _cancelEnum;
                    _enumerating = NO;
                    break;
                }
                
                if (group != nil && [group numberOfAssets] > 0) {
                    NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                    ALAssetsGroup *result = [_allALAssetsGroups objectForKey:groupPersistentID];
                    if (result == nil) {
                        DCALAssetsGroup *assetsGroup = [[DCALAssetsGroup alloc] initWithALAssetsGroup:group];
                        SAFE_ARC_AUTORELEASE(assetsGroup);
                        @synchronized(self) {
                            if (_cancelEnum) {
                                *stop = _cancelEnum;
                                _enumerating = NO;
                                break;
                            }
                            NSAssert(_allALAssetsGroupPersistentIDs, @"_allALAssetsGroupPersistentIDs == nil");
                            NSAssert(_allALAssetsGroups, @"_allALAssetsGroups == nil");
                            NSUInteger index = [_allALAssetsGroupPersistentIDs count];
                            [_allALAssetsGroupPersistentIDs insertObject:groupPersistentID atIndex:index];
                            [_allALAssetsGroups setObject:assetsGroup forKey:groupPersistentID];
                        }
                    }
                    dc_debug_NSLog(@"Add group id: %@, count = %d", groupPersistentID, [group numberOfAssets]);
                    ++_enumCount;
                    if (_enumCount == _frequency) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                        _enumCount = 0;
                        _frequency *= ALASSETSLIBRARY_FREQUENCY_FACTOR;
                    }
                } else {
                    if (_enumCount != 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                    } else {
                        NSInteger count = 0;
                        @synchronized(self) {
                            count = [_allALAssetsGroups count];
                        }
                        if (count == 0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_EMPTY object:self];
                        }
                    }
                    _enumerating = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ENUM_END object:self];
                }
            } while (NO);
        };
        
        void (^failureReporter)(NSError *error) = ^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            SAFE_ARC_AUTORELEASE(alertView);
            [alertView show];
        };
        
        @synchronized(self) {
            if (!_enumerating) {
                [self clearCache];
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                ALAssetsGroupType type = (ALAssetsGroupType)groupParam;
                NSAssert(assetsLibrary, @"_assetsLibrary == nil");
                [assetsLibrary enumerateGroupsWithTypes:type usingBlock:enumerator failureBlock:failureReporter];
            }
        }
        SAFE_ARC_AUTORELEASE_POOL_END()
    } while (NO);
}

//- (id<DCDataGroup>)assetsTimelineGroup {
//    DCALAssetsGroup *result = nil;
//    do {
//        @synchronized(self) {
//            if (!_assetsTimelineGroup) {
//                ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
//                if (!assetsLibrary) {
//                    [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _assetsLibrary == nil"];
//                    break;
//                }
//                
//                NSConditionLock *_lock = [[NSConditionLock alloc] initWithCondition:0];
//                SAFE_ARC_AUTORELEASE(_lock);
//                
//                SAFE_ARC_AUTORELEASE_POOL_START()
//                void (^enumerator)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
//                    do {
//                        if (_cancelEnum) {
//                            *stop = _cancelEnum;
//                            _enumerating = NO;
//                            break;
//                        }
//                        
//                        if (group != nil && [group numberOfAssets] > 0) {
//                            NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
//                            ALAssetsGroup *result = [_allALAssetsGroups objectForKey:groupPersistentID];
//                            if (result == nil) {
//                                @synchronized(self) {
//                                    if (_cancelEnum) {
//                                        *stop = _cancelEnum;
//                                        _enumerating = NO;
//                                        break;
//                                    }
//                                    _assetsTimelineGroup = [[DCALAssetsGroup alloc] initWithALAssetsGroup:group];
//                                }
//                            }
//                            dc_debug_NSLog(@"Add group id: %@, count = %d", groupPersistentID, [group numberOfAssets]);
//                        } else {
//                            ;
//                        }
//                    } while (NO);
//                    
//                    if ([_lock tryLockWhenCondition:0]) {
//                        [_lock unlockWithCondition:1];
//                    }
//                };
//                
//                void (^failureReporter)(NSError *error) = ^(NSError *error) {
//                    if ([_lock tryLockWhenCondition:0]) {
//                        [_lock unlockWithCondition:1];
//                    }
//                    
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    SAFE_ARC_AUTORELEASE(alertView);
//                    [alertView show];
//                };
//                
//                if (!_enumerating) {
//                    [self clearTimelineGroupCache];
//                    
//                    _cancelEnum = NO;
//                    _enumerating = YES;
//                    NSAssert(assetsLibrary, @"_assetsLibrary == nil");
//                    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:enumerator failureBlock:failureReporter];
//                    [_lock lockWhenCondition:1];
//                    [_lock unlockWithCondition:0];
//                }
//                SAFE_ARC_AUTORELEASE_POOL_END()
//            }
//            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
//            result = _assetsTimelineGroup;
//        }
//    } while (NO);
//    return result;
//}

@end
