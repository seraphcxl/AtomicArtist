//
//  DCALAssetsGroupBase.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCALAssetsGroupBase.h"

@interface DCALAssetsGroupBase () {
}

@end

@implementation DCALAssetsGroupBase

- (void)dealloc {
    do {
        @synchronized(self) {
            [self clearCache];
            
            SAFE_ARC_SAFERELEASE(_allAssetUIDs);
            SAFE_ARC_SAFERELEASE(_allAssetItems);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

#pragma mark - DCALAssetsGroupBase - DCDataGroupBase
- (DataSourceType)type {
    return DataSourceType_AssetsLib;
}

- (void)clearCache {
    do {
        @synchronized(self) {
            
            if (_allAssetUIDs) {
                [_allAssetUIDs removeAllObjects];
            }
            
            if (_allAssetItems) {
                [_allAssetItems removeAllObjects];
            }
        }
    } while (NO);
}

- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
        }
    } while (NO);
    return result;
}

- (NSUInteger)itemsCountWithParam:(id)param {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
        }
    } while (NO);
    return result;
}

- (id<DCDataItem>)itemWithUID:(NSString *)uniqueID {
    id<DCDataItem> item = nil;
    @synchronized(self) {
        if (_allAssetItems) {
            item = [_allAssetItems objectForKey:uniqueID];
            SAFE_ARC_RETAIN(item);
            SAFE_ARC_AUTORELEASE(item);
        }
    }
    return item;
}

- (NSString *)itemUIDAtIndex:(NSUInteger)index {
    NSString *result = nil;
    do {
        @synchronized(self) {
            if (_allAssetUIDs) {
                if (index < [_allAssetUIDs count]) {
                    result = [_allAssetUIDs objectAtIndex:index];
                    SAFE_ARC_RETAIN(result);
                    SAFE_ARC_AUTORELEASE(result);
                } else {
                    [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: Index: %d >= _allAssetUIDs count: %d", index, [_allAssetUIDs count]];
                }
            } else {
                [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: _allAssetUIDs is nil"];
            }
        }
    } while (NO);
    return result;
}

- (NSInteger)indexForItemUID:(NSString *)itemUID {
    NSInteger result = -1;
    do {
        if (itemUID) {
            @synchronized(self) {
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
                    [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID: %@ not find", itemUID];
                }
            }
        } else {
            [NSException raise:@"DCALAssetsGroup Error" format:@"Reason: itemUID is nil"];
        }
    } while (NO);
    return result;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    return nil;
}

@end
