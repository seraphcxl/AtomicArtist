//
//  DCALAssetsLibrary.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsLibrary.h"
#import "DCALAssetsGroup.h"

@interface DCALAssetsLibrary () {
    NSMutableArray *_allALAssetsGroupPersistentIDs;
    NSMutableDictionary *_allALAssetsGroups; // Key:(NSString *)groupPersistentID Value:(DCALAssetsGroup *)assetsGroup
    NSUInteger _frequency;
    NSUInteger _enumCount;
}

@end

@implementation DCALAssetsLibrary

@synthesize assetsLibrary = _assetsLibrary;

- (BOOL)connect:(NSDictionary *)params {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (!_allALAssetsGroups) {
        _allALAssetsGroups = [[NSMutableDictionary alloc] init];
    }
    
    if (!_allALAssetsGroupPersistentIDs) {
        _allALAssetsGroupPersistentIDs = [[NSMutableArray alloc] init];
    }
    return YES;
}

- (BOOL)disconnect {
    [self clearCache];
    
    if (_allALAssetsGroupPersistentIDs) {
        [_allALAssetsGroupPersistentIDs release];
        _allALAssetsGroupPersistentIDs = nil;
    }
    
    if (_allALAssetsGroups) {
        [_allALAssetsGroups release];
        _allALAssetsGroups = nil;
    }
    
    if (_assetsLibrary) {
        [_assetsLibrary release];
        _assetsLibrary = nil;
    }
    return YES;
}

- (void)clearCache {
    if (_allALAssetsGroupPersistentIDs) {
        [_allALAssetsGroupPersistentIDs removeAllObjects];
    }
    
    if (_allALAssetsGroups) {
        [_allALAssetsGroups removeAllObjects];
    }
}

- (void)enumGroups:(id)param notifyWithFrequency:(NSUInteger)frequency {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    void (^ALAssetsLibraryGroupsEnumerationResultsBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
		if (group != nil) {
			NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
            ALAssetsGroup *result = [_allALAssetsGroups objectForKey:groupPersistentID];
            if (result == nil) {
                DCALAssetsGroup *alAssetsGroup = [[[DCALAssetsGroup alloc] initWithALAssetsGroup:group] autorelease];
                NSUInteger index = [_allALAssetsGroupPersistentIDs count];
                [_allALAssetsGroupPersistentIDs insertObject:groupPersistentID atIndex:index];
                [_allALAssetsGroups setObject:alAssetsGroup forKey:groupPersistentID];
            }
			//Don't mark this NSLog, it is a must. Otherwise, some thing bad would happen. HAHA~~
			NSLog(@"Add group id: %@, count = %d", groupPersistentID, [group numberOfAssets]);
            ++_enumCount;
            if (_enumCount == _frequency) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAGROUP_ADDED object:self];
                _enumCount = 0;
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
        }
		
	};
    
    void (^ALAssetsLibraryAccessFailureBlock)(NSError *error) = ^(NSError *error) {
        NSInteger errCode = error.code;						 
        if (errCode == ALAssetsLibraryAccessGloballyDeniedError || errCode == ALAssetsLibraryAccessUserDeniedError) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Enum ALGroup failed" message:@"AccessGloballyDeniedError or AccessUserDeniedError" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alertView show];
        }
    };
    
    [self clearCache];
    
    if (_assetsLibrary && frequency != 0) {
        _frequency = frequency;
        _enumCount = 0;
        [_assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupType)param usingBlock:ALAssetsLibraryGroupsEnumerationResultsBlock failureBlock:ALAssetsLibraryAccessFailureBlock];
    } else {
        [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: _assetsLibrary is nil or frequency == 0"];
    }
    
    [pool drain];
}

- (NSUInteger)groupsCount {
    if (_allALAssetsGroups) {
        return [_allALAssetsGroups count];
    } else {
        return 0;
    }
}

- (id <DCDataGroup>)groupWithUID:(NSString *)uid {
    DCALAssetsGroup *result = nil;
    if (_allALAssetsGroups) {
        result = [_allALAssetsGroups objectForKey:uid];
    } else {
        [NSException raise:@"DCALAssetsLibrary error" format:@"Reason: allALGroups is nil"];
    }
    return result;
}

- (NSString *)groupUIDAtIndex:(NSUInteger)index {
    if (_allALAssetsGroupPersistentIDs) {
        if (index < [_allALAssetsGroupPersistentIDs count]) {
            return [_allALAssetsGroupPersistentIDs objectAtIndex:index];
        } else {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALAssetsGroupPersistentIDs count]];
            return nil;
        }
    } else {
        [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: allALGroupPersistentIDs is nil"];
        return nil;
    }
}

- (NSInteger)indexForGroupUID:(NSString *)groupUID {
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
            return index;
        } else {
            [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: groupUID: %@ not find", groupUID];
            return 0;
        }
    } else {
        [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: groupUID is nil"];
        return 0;
    }
}

@end
