//
//  DCAssetLibHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCAssetLibHelper.h"
#import "DCAssetsGroup.h"

static DCAssetLibHelper *staticDefaultAssetLibHelper = nil;

@interface DCAssetLibHelper () {
    ALAssetsLibrary *_assetLib;
    NSMutableArray *_allALGroupPersistentIDs;
    NSMutableDictionary *_allALGroups; // Key:(NSSString *)groupPersistentID Value:(DCAssetsGroup *)assetsGroup
}

@end

@implementation DCAssetLibHelper

- (NSUInteger)getIndexInGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL {
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
        if (assetsGroup) {
            return [assetsGroup getIndexForAssetURL:assetURL];
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

- (void)cleaeCacheForGoupPersistentID:(NSString *)groupPersistentID {
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
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
    if (_allALGroupPersistentIDs) {
        if (index < [_allALGroupPersistentIDs count]) {
            return [_allALGroupPersistentIDs objectAtIndex:index];
        } else {
            [NSException raise:@"DCAssetLibHelper Error" format:@"Reason: Index: %d >= allALGroupPersistentIDs count: %d", index, [_allALGroupPersistentIDs count]];
            return nil;
        }
    } else {
        [NSException raise:@"DCAssetLibHelper Error" format:@"Reason: allALGroupPersistentIDs is nil"];
        return nil;
    }
}

- (NSUInteger)assetCountForGroupWithPersistentID:(NSString *)groupPersistentID {
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
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
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
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
    if (_allALGroups) {
        return [_allALGroups count];
    } else {
        return 0;
    }
}

- (BOOL)enumerateAssetsForGoupPersistentID:(NSString *)groupPersistentID {
    BOOL successful = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
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
            ALAssetsGroup *result = [_allALGroups objectForKey:groupPersistentID];
            if (result == nil) {
                DCAssetsGroup *assetsGroup = [[[DCAssetsGroup alloc] init] autorelease];
                assetsGroup.assetsGroup = group;
                //                [allALGroupPersistentIDs addObject:groupPersistentID];
                NSUInteger index = [_allALGroupPersistentIDs count];
                [_allALGroupPersistentIDs insertObject:groupPersistentID atIndex:index];
                [_allALGroups setObject:assetsGroup forKey:groupPersistentID];
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
    
    if (_allALGroups) {
        [_allALGroups removeAllObjects];
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
    
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
        result = assetsGroup.assetsGroup;
    } else {
        [NSException raise:@"DCAssetLibHelper error" format:@"Reason: allALGroups is nil"];
    }
    
    return result;
}

- (ALAsset *)getALAssetForGoupPersistentID:(NSString *)groupPersistentID forAssetURL:(NSURL *)assetURL {
    ALAsset *result = nil;
    
    if (_allALGroups) {
        DCAssetsGroup *assetsGroup = [_allALGroups objectForKey:groupPersistentID];
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
    
    if (!_allALGroups) {
        _allALGroups = [[NSMutableDictionary alloc] init];
    }
    
    if (!_allALGroupPersistentIDs) {
        _allALGroupPersistentIDs = [[NSMutableArray alloc] init];
    }
}

- (void)releaseAssetLibHelper {
    [self cleaeCache];
    
    if (_allALGroupPersistentIDs) {
        [_allALGroupPersistentIDs release];
        _allALGroupPersistentIDs = nil;
    }
    
    if (_allALGroups) {
        [_allALGroups release];
        _allALGroups = nil;
    }
    
    if (_assetLib) {
        [_assetLib release];
        _assetLib = nil;
    }
}

- (void)cleaeCache {
    if (_allALGroupPersistentIDs) {
        [_allALGroupPersistentIDs removeAllObjects];
    }
    
    if (_allALGroups) {
        [_allALGroups removeAllObjects];
    }
}

@end
