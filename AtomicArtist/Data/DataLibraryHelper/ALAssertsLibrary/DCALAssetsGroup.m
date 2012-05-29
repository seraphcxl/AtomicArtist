//
//  DCALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsGroup.h"
#import "DCALAssetItem.h"
#import "DCLoadPosterImageForALAssetsGroup.h"

@interface DCALAssetsGroup () {
    NSMutableArray *_allAssetUIDs;
    NSMutableDictionary *_allAssetItems; // Key:(NSString *)assetUID Value:(DCALAssetItem *)item
    NSUInteger _frequency;
    NSUInteger _enumCount;
    BOOL _enumerated;
}

@end

@implementation DCALAssetsGroup

- (id)initWithALAssetsGroup:(ALAssetsGroup *)alAssetsGroup {
    self = [super init];
    if (self) {
        if (!_allAssetItems) {
            _allAssetItems = [[NSMutableDictionary alloc] init];
        }
        
        if (!_allAssetUIDs) {
            _allAssetUIDs = [[NSMutableArray alloc] init];
        }
        
        _alAssetsGroup = alAssetsGroup;
        [_alAssetsGroup retain];
        
        _enumerated = NO;
    }
    return self;
}

@synthesize alAssetsGroup = _alAssetsGroup;

- (NSOperation *)createOperationForLoadCachePosterImageWithItemUID:(NSString *)itemUID {
    NSOperation *result = nil;
    do {
        if (itemUID && _allAssetItems) {
            DCALAssetItem *alLAssetItem = (DCALAssetItem *)[_allAssetItems objectForKey:itemUID];
            result = [[[DCLoadPosterImageForALAssetsGroup alloc] initWithItemUID:itemUID dataGroupUID:[self uniqueID] andALAsset:alLAssetItem.alAsset] autorelease];
        }
    } while (NO);
    return result;
}

- (void)clearCache {
    if (_allAssetUIDs) {
        [_allAssetUIDs removeAllObjects];
    }
    
    if (_allAssetItems) {
        [_allAssetItems removeAllObjects];
    }
    
    _enumerated = NO;
}

- (void)dealloc {
    if (_alAssetsGroup) {
        [_alAssetsGroup release];
        _alAssetsGroup = nil;
    }
    
    [self clearCache];
    
    if (_allAssetUIDs) {
        [_allAssetUIDs release];
        _allAssetUIDs = nil;
    }
    
    if (_allAssetItems) {
        [_allAssetItems release];
        _allAssetItems = nil;
    }
    
    [super dealloc];
}

- (NSString *)uniqueID {
    if (self.alAssetsGroup) {
        return [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    } else {
        return nil;
    }
}

- (void)enumItems:(id)param notifyWithFrequency:(NSUInteger)frequency {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.alAssetsGroup) {
        if (_allAssetItems && _allAssetUIDs && frequency != 0) {
            
            [self clearCache];
            
            void (^ALAssetsGroupEnumerationResultsBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:(NSString *)param]) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSURL *url = [representation url];
                        NSString *assetURLStr = [url absoluteString];
                        
                        DCALAssetItem *item = [[[DCALAssetItem alloc] initWithALAsset:result] autorelease];
                        
                        [_allAssetItems setObject:item forKey:assetURLStr];
                        [_allAssetUIDs insertObject:assetURLStr atIndex:index];
                        ++_enumCount;
                        if (_enumCount == _frequency) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                            _enumCount = 0;
                        }
                    } else {
                        NSLog(@"Result not %@", param);
                    }
                } else {
                    if (_enumCount != 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                    }
                }
            };
            _frequency = frequency;
            _enumCount = 0;
            [self.alAssetsGroup enumerateAssetsUsingBlock:ALAssetsGroupEnumerationResultsBlock];
            _enumerated = YES;
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil or _allAssetUIDs == nil or frequency == 0"];
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
    }
    
    [pool drain];
    [pool release];
    pool = nil;
}

- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param notifyWithFrequency:(NSUInteger)frequency {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.alAssetsGroup) {
        if (_allAssetItems && _allAssetUIDs && frequency != 0) {
            
            [self clearCache];
            
            void (^ALAssetsGroupEnumerationResultsBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:(NSString *)param]) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSURL *url = [representation url];
                        NSString *assetURLStr = [url absoluteString];
                        
                        DCALAssetItem *item = [[[DCALAssetItem alloc] initWithALAsset:result] autorelease];
                        
                        [_allAssetItems setObject:item forKey:assetURLStr];
                        [_allAssetUIDs insertObject:assetURLStr atIndex:index];

                        if (index == 0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED object:[self uniqueID]];
                        }
                        
                        if (_enumCount == _frequency) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                            _enumCount = 0;
                        } else {
                            ++_enumCount;
                        }
                        
                    } else {
                        NSLog(@"Result not %@", param);
                    }
                } else {
                    if (_enumCount != 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                    }
                }
            };
            _frequency = frequency;
            _enumCount = 0;
            [self.alAssetsGroup enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:ALAssetsGroupEnumerationResultsBlock];
            
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil or _allAssetUIDs == nil or frequency == 0"];
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
    }
    
    [pool drain];
    [pool release];
    pool = nil;
}

- (NSUInteger)itemsCount {
    if (self.alAssetsGroup) {
        return [self.alAssetsGroup numberOfAssets];
    } else {
        return 0;
    }
}

- (id <DCDataItem>)itemWithUID:(NSString *)uid {
    DCALAssetItem *item = nil;
    if (_allAssetItems) {
        item = [_allAssetItems objectForKey:uid];
    }
    return item;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        if (!self.alAssetsGroup) {
            [NSException raise:@"DCALAssetsGroup error" format:@"Reason: self.alAssetsGroup == nil"];
            break;
        }
        
        if ([property isEqualToString:kDATAGROUPPROPERTY_UID]) {
            result = [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_GROUPNAME]) {
            result = [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_URL]) {
            result = [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_TYPE]) {
            result = [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyType];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_POSTERIMAGE]) {
            result = [[[UIImage alloc] initWithCGImage:[self.alAssetsGroup posterImage]] autorelease];
        } else {
            [NSException raise:@"DCALAssetsGroup error" format:@"Reason: unknown property"];
        }
    } while (NO);
    return result;
}

- (NSString *)itemUIDAtIndex:(NSUInteger)index {
    if (_allAssetUIDs) {
        if (index < [_allAssetUIDs count]) {
            return [_allAssetUIDs objectAtIndex:index];
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: Index: %d >= _allAssetUIDs count: %d", index, [_allAssetUIDs count]];
            return nil;
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetUIDs is nil"];
        return nil;
    }
}

- (NSInteger)indexForItemUID:(NSString *)itemUID {
    if (itemUID) {
        NSUInteger index = 0;
        NSUInteger count = [_allAssetUIDs count];
        BOOL find = NO;
        
        do {
            if ([_allAssetUIDs objectAtIndex:index] == itemUID) {
                find = YES;
                break;
            } else {
                ++index;
            }
        } while (index < count);
        
        if (find) {
            return index;
        } else {
            NSLog(@"itemUID: %@ not find", itemUID);
//            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID: %@ not find", itemUID];
            return -1;
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID is nil"];
        return -1;
    }
}

- (BOOL)isEnumerated {
    return _enumerated;
}

@end
