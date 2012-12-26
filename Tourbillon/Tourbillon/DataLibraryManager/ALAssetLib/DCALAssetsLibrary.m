//
//  DCALAssetsLibrary.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsLibrary.h"
#import "DCALAssetsGroup.h"

#define ALASSETSLIBRARY_FREQUENCY_FACTOR (4)

@interface DCALAssetsLibrary () {
    NSMutableArray *_allALAssetsGroupPersistentIDs;
    NSMutableDictionary *_allALAssetsGroups; // Key:(NSString *)groupPersistentID Value:(DCALAssetsGroup *)assetsGroup
    NSUInteger _frequency;
    NSUInteger _enumCount;
    
    BOOL _cancelEnum;
}

@end

@implementation DCALAssetsLibrary

@synthesize assetsLibrary = _assetsLibrary;

- (BOOL)connect:(NSDictionary *)params {
    BOOL result = NO;
    do {
        if (!_assetsLibrary) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        if (!_allALAssetsGroups) {
            _allALAssetsGroups = [[NSMutableDictionary alloc] init];
        }
        
        if (!_allALAssetsGroupPersistentIDs) {
            _allALAssetsGroupPersistentIDs = [[NSMutableArray alloc] init];
        }
        result = YES;
    } while (NO);
    return result;
}

- (BOOL)disconnect {
    BOOL result = NO;
    do {
        [self clearCache];
        dc_saferelease(_allALAssetsGroupPersistentIDs);
        dc_saferelease(_allALAssetsGroups);
        self.assetsLibrary = nil;
        result = YES;
    } while (NO);
    return result;
}

- (void)clearCache {
    do {
        _cancelEnum = YES;
        
        if (_allALAssetsGroupPersistentIDs) {
            [_allALAssetsGroupPersistentIDs removeAllObjects];
        }
        
        if (_allALAssetsGroups) {
            [_allALAssetsGroups removeAllObjects];
        }
    } while (NO);
}

- (void)enumGroups:(id)groupParam notifyWithFrequency:(NSUInteger)frequency {
    do {
        @autoreleasepool {
            void (^enumerator)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
                do {
                    if (_cancelEnum) {
                        *stop = _cancelEnum;
                        break;
                    }
                    
                    if (group != nil && [group numberOfAssets] > 0) {
                        NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                        ALAssetsGroup *result = [_allALAssetsGroups objectForKey:groupPersistentID];
                        if (result == nil) {
                            DCALAssetsGroup *assetsGroup = [[DCALAssetsGroup alloc] initWithALAssetsGroup:group];
                            dc_autorelease(assetsGroup);
                            NSUInteger index = [_allALAssetsGroupPersistentIDs count];
                            [_allALAssetsGroupPersistentIDs insertObject:groupPersistentID atIndex:index];
                            [_allALAssetsGroups setObject:assetsGroup forKey:groupPersistentID];
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
                            if ([_allALAssetsGroups count] == 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_EMPTY object:self];
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ENUM_END object:self];
                    }
                } while (NO);
            };
            
            void (^failureReporter)(NSError *error) = ^(NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                dc_autorelease(alertView);
                [alertView show];
            };
            
            [self clearCache];
            
            if (_assetsLibrary && frequency != 0) {
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                ALAssetsGroupType type = (ALAssetsGroupType)groupParam;
                [_assetsLibrary enumerateGroupsWithTypes:type usingBlock:enumerator failureBlock:failureReporter];
            } else {
                [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: _assetsLibrary is nil or frequency == 0"];
            }
        }
    } while (NO);
}

- (NSUInteger)groupsCount {
    NSUInteger result = 0;
    do {
        if (_allALAssetsGroups) {
            result = [_allALAssetsGroups count];
        }
    } while (NO);
    return result;
}

- (id<DCDataGroup>)groupWithUID:(NSString *)uid {
    DCALAssetsGroup *result = nil;
    if (_allALAssetsGroups) {
        result = [_allALAssetsGroups objectForKey:uid];
    } else {
        [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: allALGroups is nil"];
    }
    return result;
}

- (NSString *)groupUIDAtIndex:(NSUInteger)index {
    NSString *result = nil;
    do {
        if (_allALAssetsGroupPersistentIDs) {
            if (index < [_allALAssetsGroupPersistentIDs count]) {
                result = [_allALAssetsGroupPersistentIDs objectAtIndex:index];
            } else {
                [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALAssetsGroupPersistentIDs count]];
            }
        } else {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: allALGroupPersistentIDs is nil"];
        }
    } while (NO);
    return result;
}

- (NSInteger)indexForGroupUID:(NSString *)groupUID {
    NSInteger result = -1;
    do {
        if (groupUID) {
            NSUInteger index = 0;
            NSUInteger count = [_allALAssetsGroupPersistentIDs count];
            BOOL find = NO;
            
            do {
                if ([_allALAssetsGroupPersistentIDs objectAtIndex:index] == groupUID) {
                    find = YES;
                    break;
                } else {
                    ++index;
                }
            } while (index < count);
            
            if (find) {
                result = index;
            } else {
                [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: groupUID: %@ not find", groupUID];
            }
        } else {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: groupUID is nil"];
        }
    } while (NO);
    return result;
}

@end
