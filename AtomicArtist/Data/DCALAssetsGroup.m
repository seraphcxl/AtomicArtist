//
//  DCALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsGroup.h"
#import "DCALAssetItem.h"

@interface DCALAssetsGroup () {
    NSMutableArray *_allAssetUIDs;
    NSMutableDictionary *_allAssetItems; // Key:(NSString *)assetUID Value:(DCALAssetItem *)item
}

@end

@implementation DCALAssetsGroup

@synthesize alAssetsGroup = _alAssetsGroup;

- (void)clearCache {
    if (_allAssetUIDs) {
        [_allAssetUIDs removeAllObjects];
    }
    
    if (_allAssetItems) {
        [_allAssetItems removeAllObjects];
    }
}

- (void)dealloc {
    self.alAssetsGroup = nil;
    
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

- (void)enumItems:(id)param {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.alAssetsGroup) {
        if (_allAssetItems) {
            
            if (_allAssetItems) {
                [_allAssetItems removeAllObjects];
            }
            
            void (^ALAssetsGroupEnumerationResultsBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:(NSString *)param]) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSURL *url = [representation url];
                        NSString *assetURLStr = [url absoluteString];
                        
                        DCALAssetItem *item = [[[DCALAssetItem alloc] init] autorelease];
                        item.alAsset = result;
                        
                        [_allAssetItems setObject:item forKey:assetURLStr];
                        [_allAssetUIDs insertObject:assetURLStr atIndex:index];
                        
                        NSNotification *note = [NSNotification notificationWithName:@"ALAssetAdded" object:self];
                        [[NSNotificationCenter defaultCenter] postNotification:note];
                    } else {
                        NSLog(@"Result not %@", param);
                    }
                }
            };
            
            [self.alAssetsGroup enumerateAssetsUsingBlock:ALAssetsGroupEnumerationResultsBlock];
            
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: allAssets is nil"];
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: self.assetsGroup is nil"];
    }
    
    [pool drain];
}

- (NSUInteger)itemsCount {
    if (_allAssetItems) {
        return [_allAssetItems count];
    } else {
        return 0;
    }
}

- (id)itemWithUID:(NSString *)uid {
    DCALAssetItem *item = nil;
    if (_allAssetItems) {
        item = [_allAssetItems objectForKey:uid];
    }
    return item;
}

- (id)valueForProperty:(DATAGROUPPROPERTY)property {
    if (!self.alAssetsGroup) {
        [NSException raise:@"DCALAssetsGroup error" format:@"Reason: self.alAssetsGroup == nil"];
    }
    switch (property) {
        case DATAGROUPPROPERTY_UID: {
            return [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
        }
            break;
        case DATAGROUPPROPERTY_GROUPNAME: {
            return [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
        }
            break;
        case DATAGROUPPROPERTY_URL: {
            return [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        }
            break;
        case DATAGROUPPROPERTY_TYPE: {
            return [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyType];
        }
            break;
        case DATAGROUPPROPERTY_POSTERIMAGE: {
            UIImage *posterImage = [[[UIImage alloc] initWithCGImage:[self.alAssetsGroup posterImage]] autorelease];
            return posterImage;
        }
            break;
            
        default: {
            [NSException raise:@"DCALAssetsGroup error" format:@"Reason: property error"];
            return nil;
        }
            break;
    }
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

- (NSUInteger)indexForItemUID:(NSString *)itemUID {
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
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID: %@ not find", itemUID];
            return 0;
        }
    } else {
        [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID is nil"];
        return 0;
    }
}

@end
