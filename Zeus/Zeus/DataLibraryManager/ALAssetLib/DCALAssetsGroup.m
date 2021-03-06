//
//  DCALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsGroup.h"
#import "DCALAssetItem.h"
#import <UIKit/UIKit.h>

#define ALASSETSGROUP_FREQUENCY_FACTOR (8)

@interface DCALAssetsGroup () {
    NSUInteger _frequency;
    NSUInteger _enumCount;
    BOOL _enumerated;
    BOOL _cancelEnum;
    BOOL _enumerating;
}

@end

@implementation DCALAssetsGroup

@synthesize assetsGroup = _assetsGroup;
@synthesize assetType = _assetType;

#pragma mark - DCALAssetsGroup - DCDataGroupBase
- (void)clearCache {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
            
            [super clearCache];
        }
        
        _enumerated = NO;
    } while (NO);
}

- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
            if (self.assetsGroup) {
                result = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
            }
        }
    } while (NO);
    return result;
}

- (NSUInteger)itemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
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
        }
    } while (NO);
    return result;
}

#pragma mark - DCALAssetsGroup - DCDataGroup
- (void)enumItems:(id)param notifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    if (!self.assetType || (self.assetType && [[result valueForProperty:ALAssetPropertyType] isEqualToString:self.assetType])) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSString *assetURLStr = [[representation url] absoluteString];
                        
                        DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:result];
                        SAFE_ARC_AUTORELEASE(item);
                        
                        @synchronized(self) {
                            NSAssert(_allAssetItems, @"_allAssetItems == nil");
                            NSAssert(_allAssetUIDs, @"_allAssetUIDs == nil");
                            [self insertItem:item forUID:assetURLStr];
                        }
                        
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
                    _enumerating = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ENUM_END object:self];
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!self.assetsGroup) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
                break;
            }
            if (!_allAssetItems || !_allAssetUIDs) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil || _allAssetUIDs == nil"];
                break;
            }
            if (frequency == 0) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
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
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    }
                }
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                NSAssert(self.assetsGroup, @"self.assetsGroup == nil");
                [self.assetsGroup enumerateAssetsUsingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param notifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    if (!self.assetType || (self.assetType && [[result valueForProperty:ALAssetPropertyType] isEqualToString:self.assetType])) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSURL *url = [representation url];
                        NSString *assetURLStr = [url absoluteString];
                        
                        DCALAssetItem *item = [[DCALAssetItem alloc] initWithALAsset:result];
                        SAFE_ARC_AUTORELEASE(item);
                        
                        @synchronized(self) {
                            NSAssert(_allAssetItems, @"_allAssetItems == nil");
                            NSAssert(_allAssetUIDs, @"_allAssetUIDs == nil");
                            [self insertItem:item forUID:assetURLStr];
                        }
                        
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
                    _enumerating = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END object:self];
                    
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!self.assetsGroup) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup == nil"];
                break;
            }
            if (!_allAssetItems || !_allAssetUIDs) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetItems == nil || _allAssetUIDs == nil"];
                break;
            }
            if (frequency == 0) {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
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
                        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    }
                }
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                NSAssert(self.assetsGroup, @"self.assetsGroup == nil");
                [self.assetsGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (NSUInteger)enumratedItemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (_allAssetItems) {
                result = [_allAssetItems count];
            }
        }
    } while (NO);
    return result;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        @synchronized(self) {
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
                SAFE_ARC_AUTORELEASE(result);
            } else {
                [NSException raise:@"DCALAssetsGroup error" format:@"Reason: unknown property"];
            }
        }
    } while (NO);
    return result;
}

- (BOOL)isEnumerated {
    return _enumerated;
}

- (BOOL)isEnumerating {
    return _enumerating;
}

#pragma mark - DCALAssetsGroup - Public
- (id)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        @synchronized(self) {
            if (!_allAssetItems) {
                _allAssetItems = [NSMutableDictionary dictionary];
                SAFE_ARC_RETAIN(_allAssetItems);
            }
            
            if (!_allAssetUIDs) {
                _allAssetUIDs = [NSMutableArray array];
                SAFE_ARC_RETAIN(_allAssetUIDs);
            }
            
            self.assetsGroup = assetsGroup;
        }
        
        _enumerated = NO;
        _cancelEnum = NO;
        _enumerating = NO;
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_assetsGroup);
            SAFE_ARC_SAFERELEASE(_assetType);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

@end
