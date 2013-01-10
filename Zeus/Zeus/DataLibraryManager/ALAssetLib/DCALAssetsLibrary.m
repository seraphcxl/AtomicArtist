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
    NSMutableArray *_allALAssetsGroupPersistentIDs;
    NSMutableDictionary *_allALAssetsGroups; // Key:(NSString *)groupPersistentID Value:(DCALAssetsGroup *)assetsGroup
    NSUInteger _frequency;
    NSUInteger _enumCount;
    
    BOOL _cancelEnum;
    BOOL _enumerating;
}

- (void)assetsLibChanged:(NSNotification *)note;

@end

@implementation DCALAssetsLibrary

@synthesize assetsLibrary = _assetsLibrary;

- (BOOL)connect:(NSDictionary *)params {
    BOOL result = NO;
    do {
        @synchronized(self) {
            if (!_assetsLibrary) {
                _assetsLibrary = [[ALAssetsLibrary alloc] init];
            }
            
            if (!_allALAssetsGroups) {
                _allALAssetsGroups = [[NSMutableDictionary alloc] init];
            }
            
            if (!_allALAssetsGroupPersistentIDs) {
                _allALAssetsGroupPersistentIDs = [[NSMutableArray alloc] init];
            }
            _cancelEnum = NO;
            _enumerating = NO;
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(assetsLibChanged:) name:ALAssetsLibraryChangedNotification object:nil];
        }
        result = YES;
    } while (NO);
    return result;
}

- (BOOL)disconnect {
    BOOL result = NO;
    do {
        [self clearCache];
        
        @synchronized(self) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter removeObserver:self];
            
            SAFE_ARC_SAFERELEASE(_allALAssetsGroupPersistentIDs);
            SAFE_ARC_SAFERELEASE(_allALAssetsGroups);
            self.assetsLibrary = nil;
        }
        
        result = YES;
    } while (NO);
    return result;
}

- (void)clearCache {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
            
            if (_allALAssetsGroupPersistentIDs) {
                [_allALAssetsGroupPersistentIDs removeAllObjects];
            }
            
            if (_allALAssetsGroups) {
                [_allALAssetsGroups removeAllObjects];
            }
        }
    } while (NO);
}

- (void)enumGroups:(id)groupParam notifyWithFrequency:(NSUInteger)frequency {
    do {
        if (!_assetsLibrary) {
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
        
        [self clearCache];
        
        @synchronized(self) {
            _frequency = frequency;
            _enumCount = 0;
            _cancelEnum = NO;
            _enumerating = YES;
            ALAssetsGroupType type = (ALAssetsGroupType)groupParam;
            NSAssert(_assetsLibrary, @"_assetsLibrary == nil");
            [_assetsLibrary enumerateGroupsWithTypes:type usingBlock:enumerator failureBlock:failureReporter];
        }
        SAFE_ARC_AUTORELEASE_POOL_END()
    } while (NO);
}

- (NSUInteger)groupsCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (_allALAssetsGroups) {
                result = [_allALAssetsGroups count];
            }
        }
    } while (NO);
    return result;
}

- (id<DCDataGroup>)groupWithUID:(NSString *)uid {
    DCALAssetsGroup *result = nil;
    @synchronized(self) {
        if (_allALAssetsGroups) {
            result = [_allALAssetsGroups objectForKey:uid];
        } else {
            [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: allALGroups is nil"];
        }
    }
    return result;
}

- (NSString *)groupUIDAtIndex:(NSUInteger)index {
    NSString *result = nil;
    do {
        @synchronized(self) {
            if (_allALAssetsGroupPersistentIDs) {
                if (index < [_allALAssetsGroupPersistentIDs count]) {
                    result = [_allALAssetsGroupPersistentIDs objectAtIndex:index];
                } else {
                    [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALAssetsGroupPersistentIDs count]];
                }
            } else {
                [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: allALGroupPersistentIDs is nil"];
            }
        }
    } while (NO);
    return result;
}

- (NSInteger)indexForGroupUID:(NSString *)groupUID {
    NSInteger result = -1;
    do {
        if (groupUID) {
            @synchronized(self) {
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
            }
        } else {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: groupUID is nil"];
        }
    } while (NO);
    return result;
}

- (BOOL)isEnumerating {
    return _enumerating;
}

- (void)assetsLibChanged:(NSNotification *)note {
    do {
        ;
    } while (NO);
}

@end
