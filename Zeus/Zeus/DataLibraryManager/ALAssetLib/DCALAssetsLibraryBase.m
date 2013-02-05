//
//  DCALAssetsLibraryBase.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCALAssetsLibraryBase.h"

@interface DCALAssetsLibraryBase () {
}

@end

@implementation DCALAssetsLibraryBase

#pragma mark - DCALAssetsLibraryBase - DCDataLibraryBase
- (DataSourceType)type {
    return DataSourceType_AssetsLib;
}

- (BOOL)connect:(NSDictionary *)params {
    BOOL result = NO;
    do {
        @synchronized(self) {
            [self initAssetsLib];
        }
        result = YES;
    } while (NO);
    return result;
}

- (BOOL)disconnect {
    BOOL result = NO;
    do {
        @synchronized(self) {
            [self uninitAssetsLib];
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

- (id<DCDataGroupBase>)groupWithUID:(NSString *)uniqueID {
    id<DCDataGroupBase> result = nil;
    @synchronized(self) {
        if (_allALAssetsGroups) {
            result = [_allALAssetsGroups objectForKey:uniqueID];
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

#pragma mark - DCALAssetsLibraryBase - DCAssetsLibUser
- (void)nofityAssetsLibStable {
    do {
        @synchronized(self) {
            [self uninitAssetsLib];
            [self initAssetsLib];
            
        }
    } while (NO);
}

#pragma mark - DCALAssetsLibraryBase - Public
- (void)initAssetsLib {
    do {
        @synchronized(self) {
            if (!_allALAssetsGroups) {
                _allALAssetsGroups = [[NSMutableDictionary alloc] init];
            }
            
            if (!_allALAssetsGroupPersistentIDs) {
                _allALAssetsGroupPersistentIDs = [[NSMutableArray alloc] init];
            }
            _cancelEnum = NO;
            _enumerating = NO;
            
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] addAssetsLibUser:self];
        }
    } while (NO);
}

- (void)uninitAssetsLib {
    do {
        @synchronized(self) {
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] removeAssetsLibUser:self];
            
            [self clearCache];
            
            SAFE_ARC_SAFERELEASE(_allALAssetsGroupPersistentIDs);
            SAFE_ARC_SAFERELEASE(_allALAssetsGroups);
        }
    } while (NO);
}
@end
