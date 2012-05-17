//
//  DCAssetLibHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCAssetLibHelper.h"
#import "DCAssetsGroup.h"

static DCAssetLibHelper *staticDefaultAssetLibHelper = nil;

@interface DCAssetLibHelper () {
    ALAssetsLibrary *_assetLib;
    NSMutableArray *_allALAssetsGroupPersistentIDs;
    NSMutableDictionary *_allALAssetsGroups; // Key:(NSSString *)groupPersistentID Value:(DCAssetsGroup *)assetsGroup
}

@end

@implementation DCAssetLibHelper

- (NSUInteger)getIndexInGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL {
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            return [assetsGroup getIndexForAssetURL:assetURL];
        } else {
            NSLog(@"Reason: assetsGroup for %@ not find", groupPersistentID);
            return 0;
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
        return 0;
    }
}

- (void)cleaeCacheForGoupPersistentID:(NSString *)groupPersistentID {
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            [assetsGroup cleaeCache];
        } else {
            [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetsGroup for %@ not find", groupPersistentID];
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
    }
    
}

- (NSString *)getGoupPersistentIDAtIndex:(NSUInteger)index {
    if (_allALAssetsGroupPersistentIDs) {
        if (index < [_allALAssetsGroupPersistentIDs count]) {
            return [_allALAssetsGroupPersistentIDs objectAtIndex:index];
        } else {
            [NSException raise:@"DCAssetLibHelper Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALAssetsGroupPersistentIDs count]];
            return nil;
        }
    } else {
        [NSException raise:@"DCAssetLibHelper Error" format:@"Reason: allALGroupPersistentIDs is nil"];
        return nil;
    }
}

- (NSUInteger)assetCountForGroupWithPersistentID:(NSString *)groupPersistentID {
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            return [assetsGroup assetCount];
        } else {
            //            [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetsGroup for %@ not find", groupPersistentID];
            NSLog(@"Reason: assetsGroup for %@ not find", groupPersistentID);
            return 0;
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
        return 0;
    }
}

- (NSURL *)getAssetURLForGoupPersistentID:(NSString *)groupPersistentID atIndex:(NSUInteger)index {
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            return [assetsGroup getAssetURLAtIndex:index];
        } else {
            [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetsGroup for %@ not find", groupPersistentID];
            return nil;
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
        return nil;
    }
}

- (NSUInteger)assetsGroupCount {
    if (_allALAssetsGroups) {
        return [_allALAssetsGroups count];
    } else {
        return 0;
    }
}

- (BOOL)enumerateAssetsForGoupPersistentID:(NSString *)groupPersistentID {
    BOOL successful = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            successful = [assetsGroup enumerateAssets];
        } else {
            [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetsGroup for %@ not find", groupPersistentID];
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
    }
    
    [pool drain];
    return successful;
}

- (BOOL)enumerateGroupsWithTypes:(ALAssetsGroupType)types {
    BOOL successful = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    void (^ALAssetsLibraryGroupsEnumerationResultsBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
		if (group != nil) {
			NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
            ALAssetsGroup *result = [_allALAssetsGroups objectForKey:groupPersistentID];
            if (result == nil) {
                DCAssetsGroup *assetsGroup = [[[DCAssetsGroup alloc] init] autorelease];
                assetsGroup.assetsGroup = group;
                //                [allALGroupPersistentIDs addObject:groupPersistentID];
                NSUInteger index = [_allALAssetsGroupPersistentIDs count];
                [_allALAssetsGroupPersistentIDs insertObject:groupPersistentID atIndex:index];
                [_allALAssetsGroups setObject:assetsGroup forKey:groupPersistentID];
            }
			//Don't mark this NSLog, it is a must. Otherwise, some thing bad would happen. HAHA~~
			NSLog(@"Add group id: %@, count = %d", groupPersistentID, [group numberOfAssets]);
		}
		NSNotification *note = [NSNotification notificationWithName:@"ALGroupAdded" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
	};
    
    void (^ALAssetsLibraryAccessFailureBlock)(NSError *error) = ^(NSError *error) {
        NSInteger errCode = error.code;						 
        if (errCode == ALAssetsLibraryAccessGloballyDeniedError || errCode == ALAssetsLibraryAccessUserDeniedError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALGroup failed" message:@"AccessGloballyDeniedError or AccessUserDeniedError" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            alertView = nil;
        }
    };
    
    if (_allALAssetsGroups) {
        [_allALAssetsGroups removeAllObjects];
    }
    
    if (_assetLib) {
        [_assetLib enumerateGroupsWithTypes:types usingBlock:ALAssetsLibraryGroupsEnumerationResultsBlock failureBlock:ALAssetsLibraryAccessFailureBlock];
        successful = YES;
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetLib is nil"];
    }
    
    [pool drain];
    return successful;
}

- (ALAssetsGroup *)getALGroupForGoupPersistentID:(NSString *)groupPersistentID {
    ALAssetsGroup *result = nil;
    
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        result = assetsGroup.assetsGroup;
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
    }
    
    return result;
}

- (ALAsset *)getALAssetForGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL {
    ALAsset *result = nil;
    
    if (_allALAssetsGroups) {
        DCAssetsGroup *assetsGroup = [_allALAssetsGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            result = [assetsGroup getALAssetForAssetURL:assetURL];
        } else {
            [NSException raise:@"DCAssetLibHelper error" format:@"Reason: assetsGroup for %@ is nil", groupPersistentID]; 
        }
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
    }
    
    return result;
}

+ (DCAssetLibHelper *)defaultAssetLibHelper {
    if (!staticDefaultAssetLibHelper) {
        staticDefaultAssetLibHelper = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultAssetLibHelper;
}

+ (void)staticRelease {
    if (!staticDefaultAssetLibHelper) {
        [staticDefaultAssetLibHelper release];
        staticDefaultAssetLibHelper = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultAssetLibHelper];
}

- (id)init {
    [super init];
    
    [self createAssetLibHelper];
    
    return self;
}

- (void)createAssetLibHelper {
    if (!_assetLib) {
        _assetLib = [[ALAssetsLibrary alloc] init];
    }
    
    if (!_allALAssetsGroups) {
        _allALAssetsGroups = [[NSMutableDictionary alloc] init];
    }
    
    if (!_allALAssetsGroupPersistentIDs) {
        _allALAssetsGroupPersistentIDs = [[NSMutableArray alloc] init];
    }
}

- (void)releaseAssetLibHelper {
    [self cleaeCache];
    
    if (_allALAssetsGroupPersistentIDs) {
        [_allALAssetsGroupPersistentIDs release];
        _allALAssetsGroupPersistentIDs = nil;
    }
    
    if (_allALAssetsGroups) {
        [_allALAssetsGroups release];
        _allALAssetsGroups = nil;
    }
    
    if (_assetLib) {
        [_assetLib release];
        _assetLib = nil;
    }
}

- (void)cleaeCache {
    if (_allALAssetsGroupPersistentIDs) {
        [_allALAssetsGroupPersistentIDs removeAllObjects];
    }
    
    if (_allALAssetsGroups) {
        [_allALAssetsGroups removeAllObjects];
    }
}

@end
