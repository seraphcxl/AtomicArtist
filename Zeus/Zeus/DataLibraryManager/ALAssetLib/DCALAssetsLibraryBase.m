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
            
            @synchronized(_allALAssetsGroupUIDs) {
                if (_allALAssetsGroupUIDs) {
                    [_allALAssetsGroupUIDs removeAllObjects];
                }
            }
            
            @synchronized(_allALAssetsGroups) {
                if (_allALAssetsGroups) {
                    [_allALAssetsGroups removeAllObjects];
                }
            }
        }
    } while (NO);
}

- (NSUInteger)groupsCount {
    NSUInteger result = 0;
    do {
        @synchronized(_allALAssetsGroups) {
            if (_allALAssetsGroups) {
                result = [_allALAssetsGroups count];
            }
        }
    } while (NO);
    return result;
}

- (id<DCDataGroupBase>)groupWithUID:(NSString *)uniqueID {
    id<DCDataGroupBase> result = nil;
    @synchronized(_allALAssetsGroups) {
        if (_allALAssetsGroups) {
            result = [_allALAssetsGroups objectForKey:uniqueID];
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
        } else {
            [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: allALGroups is nil"];
        }
    }
    return result;
}

- (NSString *)groupUIDAtIndex:(NSUInteger)index {
    NSString *result = nil;
    do {
        NSUInteger count = [_allALAssetsGroupUIDs count];
        if (index < count) {
            @synchronized(_allALAssetsGroupUIDs) {
                if (_allALAssetsGroupUIDs) {
                    if (index < [_allALAssetsGroupUIDs count]) {
                        result = [_allALAssetsGroupUIDs objectAtIndex:index];
                        SAFE_ARC_RETAIN(result);
                        SAFE_ARC_AUTORELEASE(result);
                    } else {
                        [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALAssetsGroupUIDs count]];
                    }
                } else {
                    [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: allALGroupPersistentIDs is nil"];
                }
            }
        }
    } while (NO);
    return result;
}

- (NSInteger)indexForGroupUID:(NSString *)groupUID {
    NSInteger result = -1;
    do {
        if (groupUID) {
            @synchronized(_allALAssetsGroupUIDs) {
                NSUInteger index = 0;
                NSUInteger count = [_allALAssetsGroupUIDs count];
                BOOL find = NO;
                
                do {
                    if ([_allALAssetsGroupUIDs objectAtIndex:index] == groupUID) {
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
            @synchronized(_allALAssetsGroups) {
                if (!_allALAssetsGroups) {
                    _allALAssetsGroups = [NSMutableDictionary dictionary];
                    SAFE_ARC_RETAIN(_allALAssetsGroups);
                }
            }
            
            @synchronized(_allALAssetsGroupUIDs) {
                if (!_allALAssetsGroupUIDs) {
                    _allALAssetsGroupUIDs = [NSMutableArray array];
                    SAFE_ARC_RETAIN(_allALAssetsGroupUIDs);
                }
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
            
            @synchronized(_allALAssetsGroups) {
                SAFE_ARC_SAFERELEASE(_allALAssetsGroups);
            }
            
            @synchronized(_allALAssetsGroupUIDs) {
                SAFE_ARC_SAFERELEASE(_allALAssetsGroupUIDs);
            }
        }
    } while (NO);
}

- (void)insertGroup:(id<DCDataGroupBase>)group forUID:(NSString *)uid {
    do {
        if (!group || !uid) {
            break;
        }
        @synchronized(_allALAssetsGroups) {
            @synchronized(_allALAssetsGroupUIDs) {
                if (!_allALAssetsGroups || !_allALAssetsGroupUIDs) {
                    break;
                }
                NSUInteger index = [_allALAssetsGroupUIDs count];
                [_allALAssetsGroupUIDs insertObject:uid atIndex:index];
                [_allALAssetsGroups setObject:group forKey:uid];
                if ([_allALAssetsGroupUIDs count] == 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_FRISTADDED object:self];
                }
            }
        }
    } while (NO);
}
@end
