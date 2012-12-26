//
//  DCALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsGroup.h"
#import "DCALAssetItem.h"

#define ALASSETSGROUP_FREQUENCY_FACTOR (8)

@interface DCALAssetsGroup () {
    NSMutableArray *_allAssetUIDs;
    NSMutableDictionary *_allAssetItems; // Key:(NSString *)assetUID Value:(DCALAssetItem *)item
    NSUInteger _frequency;
    NSUInteger _enumCount;
    BOOL _enumerated;
    BOOL _cancelEnum;
}

@end

@implementation DCALAssetsGroup

@synthesize assetsGroup = _assetsGroup;
@synthesize assetType = _assetType;

- (id)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        if (!_allAssetItems) {
            _allAssetItems = [[NSMutableDictionary alloc] init];
        }
        
        if (!_allAssetUIDs) {
            _allAssetUIDs = [[NSMutableArray alloc] init];
        }
        
        self.assetsGroup = assetsGroup;
        
        _enumerated = NO;
    }
    return self;
}

- (void)clearCache {
    do {
        _cancelEnum = YES;
        
        if (_allAssetUIDs) {
            [_allAssetUIDs removeAllObjects];
        }
        
        if (_allAssetItems) {
            [_allAssetItems removeAllObjects];
        }
        
        _enumerated = NO;
    } while (NO);
}

- (void)dealloc {
    do {
        [self clearCache];
        
        dc_saferelease(_allAssetUIDs);
        dc_saferelease(_allAssetItems);
        
        self.assetsGroup = nil;
        dc_saferelease(_assetType);
        dc_dealloc(super);
    } while (NO);
}

- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        if (self.assetsGroup) {
            result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
        }
    } while (NO);
    return result;
}

- (void)enumItems:(id)param notifyWithFrequency:(NSUInteger)frequency {
    do {
        if (!self.assetsGroup) {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
            break;
        }
        @autoreleasepool {
            if (_allAssetItems && _allAssetUIDs && frequency != 0) {
                
                [self clearCache];
                
                void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    do {
                        if (_cancelEnum) {
                            *stop = YES;
                            break;
                        }
                        
                        if (result != nil) {
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:self.assetType]) {
                                ALAssetRepresentation *representation = [result defaultRepresentation];
                                NSString *assetURLStr = [[representation url] absoluteString];
                                
                                DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:result];
                                dc_autorelease(item);
                                
                                [_allAssetItems setObject:item forKey:assetURLStr];
                                NSUInteger indexForAsset = [_allAssetUIDs count];
                                [_allAssetUIDs insertObject:assetURLStr atIndex:indexForAsset];
                                ++_enumCount;
                                if (_enumCount == _frequency) {
                                    _enumerated = YES;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                                    _enumCount = 0;
                                    _frequency *= ALASSETSGROUP_FREQUENCY_FACTOR;
                                }
                            } else {
                                [NSException raise:@"DCALAssetsGroup Error" format:@"Result is %@ not %@", [result valueForProperty:ALAssetPropertyType], self.assetType];
                            }
                        } else {
                            if (_enumCount != 0) {
                                _enumerated = YES;
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ENUM_END object:self];
                        }
                    } while (NO);
                };
                
                if (_assetType != (NSString *)param) {
                    _assetType = (NSString *)param;
                    
                    if ([ALAssetTypePhoto isEqualToString:self.assetType]) {
                        dc_debug_NSLog(@"ALAssetsGroup photo");
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    } else if ([ALAssetTypeVideo isEqualToString:self.assetType]) {
                        dc_debug_NSLog(@"ALAssetsGroup video");
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    } else {
                        dc_debug_NSLog(@"ALAssetsGroup photo and video");
                    }
                }
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                [self.assetsGroup enumerateAssetsUsingBlock:enumerator];
            } else {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil or _allAssetUIDs == nil or frequency == 0"];
            }
        }
    } while (NO);
}

- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param notifyWithFrequency:(NSUInteger)frequency {
    do {
        if (!self.assetsGroup) {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
            break;
        }
        @autoreleasepool {
            if (_allAssetItems && _allAssetUIDs && frequency != 0) {
                
                [self clearCache];
                
                void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    do {
                        if (_cancelEnum) {
                            *stop = YES;
                            break;
                        }
                        
                        if (result != nil) {
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:self.assetType]) {
                                ALAssetRepresentation *representation = [result defaultRepresentation];
                                NSURL *url = [representation url];
                                NSString *assetURLStr = [url absoluteString];
                                
                                DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:result];
                                dc_autorelease(item);
                                
                                [_allAssetItems setObject:item forKey:assetURLStr];
                                NSUInteger indexForAsset = [_allAssetUIDs count];
                                [_allAssetUIDs insertObject:assetURLStr atIndex:indexForAsset];
                                
                                if (index == 0) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED object:[self uniqueID]];
                                }
                                
                                ++_enumCount;
                                if (_enumCount == _frequency) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                                    _enumCount = 0;
                                    _frequency *= ALASSETSGROUP_FREQUENCY_FACTOR;
                                }
                            } else {
                                [NSException raise:@"DCALAssetsGroup Error" format:@"Result is %@ not %@", [result valueForProperty:ALAssetPropertyType], self.assetType];
                            }
                        } else {
                            if (_enumCount != 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ADDED object:[self uniqueID]];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END object:self];
                            
                        }
                    } while (NO);
                };
                
                if (_assetType != (NSString *)param) {
                    _assetType = (NSString *)param;
                    
                    if ([ALAssetTypePhoto isEqualToString:self.assetType]) {
                        dc_debug_NSLog(@"ALAssetsGroup photo");
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    } else if ([ALAssetTypeVideo isEqualToString:self.assetType]) {
                        dc_debug_NSLog(@"ALAssetsGroup video");
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    } else {
                        dc_debug_NSLog(@"ALAssetsGroup photo and video");
                    }
                }
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                [self.assetsGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:enumerator];
                
            } else {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil or _allAssetUIDs == nil or frequency == 0"];
            }
        }
    } while (NO);
}

- (NSUInteger)itemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        if (self.assetsGroup) {
            
            if (_assetType != (NSString *)param) {
                _assetType = (NSString *)param;
                
                if ([ALAssetTypePhoto isEqualToString:self.assetType]) {
                    dc_debug_NSLog(@"ALAssetsGroup photo");
                    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                } else if ([ALAssetTypeVideo isEqualToString:self.assetType]) {
                    dc_debug_NSLog(@"ALAssetsGroup video");
                    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                } else {
                    dc_debug_NSLog(@"ALAssetsGroup photo and video");
                }
            }
            
            result = [self.assetsGroup numberOfAssets];
        }
    } while (NO);
    return result;
}

- (NSUInteger)enumratedItemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        if (_allAssetItems) {
            result = [_allAssetItems count];
        }
    } while (NO);
    return result;
}

- (id<DCDataItem>)itemWithUID:(NSString *)uid {
    DCALAssetItem *item = nil;
    if (_allAssetItems) {
        item = [_allAssetItems objectForKey:uid];
    }
    return item;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        if (!self.assetsGroup) {
            [NSException raise:@"DCALAssetsGroup error" format:@"Reason: self.alAssetsGroup == nil"];
            break;
        }
        
        if ([property isEqualToString:kDATAGROUPPROPERTY_UID]) {
            result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_GROUPNAME]) {
            result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_URL]) {
            result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_TYPE]) {
            result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyType];
        } else if ([property isEqualToString:kDATAGROUPPROPERTY_POSTERIMAGE]) {
            result = [[UIImage alloc] initWithCGImage:[self.assetsGroup posterImage]];
            dc_autorelease(result);
        } else {
            [NSException raise:@"DCALAssetsGroup error" format:@"Reason: unknown property"];
        }
    } while (NO);
    return result;
}

- (NSString *)itemUIDAtIndex:(NSUInteger)index {
    NSString *result = nil;
    do {
        if (_allAssetUIDs) {
            if (index < [_allAssetUIDs count]) {
                result = [_allAssetUIDs objectAtIndex:index];
            } else {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: Index: %d >= _allAssetUIDs count: %d", index, [_allAssetUIDs count]];
            }
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetUIDs is nil"];
        }
    } while (NO);
    return result;
}

- (NSInteger)indexForItemUID:(NSString *)itemUID {
    NSInteger result = -1;
    do {
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
                result = index;
            } else {
                dc_debug_NSLog(@"itemUID: %@ not find", itemUID);
//                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID: %@ not find", itemUID];
            }
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID is nil"];
        }
    } while (NO);
    return result;
}

- (BOOL)isEnumerated {
    return _enumerated;
}

@end
