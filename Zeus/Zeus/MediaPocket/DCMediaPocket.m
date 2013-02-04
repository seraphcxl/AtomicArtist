//
//  DCMediaPocket.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaPocket.h"
#import "DCALAssetItem.h"
#import "DCMediaPocketDataItem.h"

NSString * const NOTIFY_MEDIAPOCKET_INSERTED = @"NOTIFY_MEDIAPOCKET_INSERTED";
NSString * const NOTIFY_MEDIAPOCKET_REMOVED = @"NOTIFY_MEDIAPOCKET_REMOVED";
NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME = @"NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME";
NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF = @"NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF";

@interface DCMediaPocket () {
    NSMutableArray *_array;  // valve:(id<ASMediaDataItem>)
    NSMutableDictionary *_dict;  // key:(NSString *) valve:(id<ASMediaDataItem>)
}

- (void)clean;

- (DataSourceType)typeForUID:(NSString *)uniqueID;

@end

@implementation DCMediaPocket

@synthesize cameraActionDelegate = _cameraActionDelegate;
@synthesize allowRemoveWhenUseCountIsZero = _allowRemoveWhenUseCountIsZero;

DEFINE_SINGLETON_FOR_CLASS(DCMediaPocket);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            [self reset];
            _allowRemoveWhenUseCountIsZero = NO;
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] addAssetsLibUser:self];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _cameraActionDelegate = nil;
            
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] removeAssetsLibUser:self];
            
            [self clean];
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)clean {
    @synchronized (self) {
        if (_array) {
            [_array removeAllObjects];
            SAFE_ARC_SAFERELEASE(_array);
            _array = nil;
        }
        
        if (_dict) {
            [_dict removeAllObjects];
            SAFE_ARC_SAFERELEASE(_dict);
            _dict = nil;
        }
    }
}

- (void)reset {
    @synchronized (self) {
        [self clean];
        
        _array = [[NSMutableArray alloc] init];
        
        _dict = [[NSMutableDictionary alloc] init];
    }
}

- (void)clearUseCountForItems {
    do {
        @synchronized (self) {
            for (id<DCMediaPocketDataItemProtocol> item in _array) {
                [item zeroUseCount];
            }
        }
    } while (NO);
}

- (NSUInteger)itemCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            result = [_array count];
        }
    } while (NO);
    return result;
}

- (id<DCMediaPocketDataItemProtocol>)findItem:(NSString *)uniqueID {
    id result = nil;
    do {
        if (!uniqueID) {
            break;
        }
        @synchronized(self) {
            if (!_array || !_dict || [_array count] == 0) {
                break;
            }
            
            result = [_dict objectForKey:uniqueID];
        }
    } while (NO);
    return result;
}

- (id<DCMediaPocketDataItemProtocol>)itemAtIndex:(NSUInteger)index {
    id result = nil;
    do {
        @synchronized(self) {
            if (!_array || !_dict || [_array count] <= index) {
                break;
            }
            
            result = [_array objectAtIndex:index];
        }
    } while (NO);
    return result;
}

- (void)updateItem:(id<DCMediaPocketDataItemProtocol>)item forUID:(NSString *)uniqueID {
    do {
        if (!item || !uniqueID) {
            break;
        }
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            
            NSUInteger index = 0;
            for (id<DCMediaPocketDataItemProtocol> oldItem in _array) {
                NSString *oldUID = [oldItem uniqueID];
                if ([oldUID isEqualToString:uniqueID]) {
                    BOOL same = NO;
                    if ([[oldItem md5] isEqualToString:[item md5]]) {
                        same = YES;
                    } else {
                        same = NO;
                    }
                    
                    [self removeItemAtIndex:index];
                    [self insertItem:item atIndex:index];
                    
                    NSString *notify = nil;
                    if (same) {
                        notify = NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME;
                    } else {
                        notify = NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify object:uniqueID];
                    break;
                }
                ++index;
            }
        }
    } while (NO);
}

- (void)increaseUseCountForItem:(NSString *)uniqueID {
    do {
        if (!uniqueID) {
            break;
        }
        @synchronized(self) {
            id<DCMediaPocketDataItemProtocol> item = [self findItem:uniqueID];
            if (!item) {
                break;
            }
            [item increaseUseCount];
        }
    } while (NO);
}

- (void)decreaseUseCountForItem:(NSString *)uniqueID {
    do {
        if (!uniqueID) {
            break;
        }
        @synchronized(self) {
            id<DCMediaPocketDataItemProtocol> item = [self findItem:uniqueID];
            if (!item) {
                break;
            }
            NSUInteger useCount = [item decreaseUseCount];
            if (useCount == 0 && self.allowRemoveWhenUseCountIsZero) {
                [self removeItem:uniqueID];
            }
        }
    } while (NO);
}

- (void)insertItem:(id<DCMediaPocketDataItemProtocol>)item atIndex:(NSUInteger)index {
    do {
        if (!item) {
            break;
        }
        @synchronized(self) {
            if (!_array || !_dict || [_array count] < index) {
                break;
            }
            
            [_array insertObject:item atIndex:index];
            [_dict setObject:item forKey:[item uniqueID]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_INSERTED object:[item uniqueID]];
        }
    } while (NO);
}

- (void)topInsertItem:(id<DCMediaPocketDataItemProtocol>)item {
    do {
        if (!item) {
            break;
        }
        [self insertItem:item atIndex:0];
    } while (NO);
}

- (void)bottomInsertItem:(id<DCMediaPocketDataItemProtocol>)item {
    do {
        if (!item) {
            break;
        }
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            [self insertItem:item atIndex:[_array count]];
        }
    } while (NO);
}

- (void)removeItemAtIndex:(NSUInteger)index {
    do {
        @synchronized(self) {
            if (!_array || !_dict || [_array count] <= index) {
                break;
            }
            
            NSString *uid = [[_array objectAtIndex:index] uniqueID];
            [self removeItem:uid];
        }
    } while (NO);
}

- (void)topRemoveItem {
    do {
        [self removeItemAtIndex:0];
    } while (NO);
}

- (void)bottomRemoveItem {
    do {
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            [self removeItemAtIndex:([_array count] - 1)];
        }
    } while (NO);
}

- (void)removeItem:(NSString *)uniqueID {
    do {
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            
            id<DCMediaPocketDataItemProtocol> item = [_dict objectForKey:uniqueID];
            [_array removeObject:item];
            item = nil;
            [_dict removeObjectForKey:uniqueID];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_REMOVED object:uniqueID];
        }
    } while (NO);
}

- (void)moveItemFrom:(NSUInteger)from to:(NSUInteger)to {
    do {
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            
            NSUInteger count = [_array count];
            if (count <= from || count <= to) {
                break;
            }
            
            id<DCMediaPocketDataItemProtocol> item = [_array objectAtIndex:from];
            SAFE_ARC_RETAIN(item);
            [_array removeObjectAtIndex:from];
            [_array insertObject:item atIndex:to];
            SAFE_ARC_SAFERELEASE(item);
            item = nil;
        }
    } while (NO);
}

- (void)nofityAssetsLibStable {
    do {
        ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
        if (!assetsLibrary) {
            break;
        }
        @synchronized(self) {
            for (id<DCMediaPocketDataItemProtocol> item in _array) {
                if ([item type] == DataSourceType_AssetsLib) {
                    __block NSURL *url = [item URL];
                    __block NSString *uid = [item uniqueID];
                    __block NSUInteger useCount = [item useCount];
                    
                    void (^assetResultBlock)(ALAsset *asset) = ^(ALAsset *asset) {
                        do {
                            if (!asset) {
                                break;
                            }
                            DCALAssetItem *dataItem = [[DCALAssetItem alloc] initWithALAsset:asset];
                            SAFE_ARC_AUTORELEASE(dataItem);
                            DCMediaPocketDataItem *mediaPocketDataItem = [[DCMediaPocketDataItem alloc] initWithDataItem:dataItem andUseCount:useCount];
                            SAFE_ARC_AUTORELEASE(mediaPocketDataItem);
                            NSAssert([uid isEqualToString:[mediaPocketDataItem uniqueID]], @"uid not equal.");
                            
                            [self updateItem:mediaPocketDataItem forUID:uid];
                        } while (NO);
                    };
                    
                    void (^failureBlock)(NSError *error) = ^(NSError *error) {
                        dc_debug_NSLog(@"%@", [error localizedDescription]);
                    };
                    
                    [assetsLibrary assetForURL:url resultBlock:assetResultBlock failureBlock:failureBlock];
                }
                
            }
        }
    } while (NO);
}

- (void)insertPhotoFromImagePicker:(CGImageRef)cgImg orientation:(ALAssetOrientation)assetOrientation {
    do {
        if (!cgImg) {
            break;
        }
        ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
        if (!assetsLibrary) {
            break;
        }
        [assetsLibrary writeImageToSavedPhotosAlbum:cgImg orientation:assetOrientation completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                ;
            } else {
                void (^assetResultBlock)(ALAsset *asset) = ^(ALAsset *asset) {
                    do {
                        if (!asset) {
                            break;
                        }
                        @synchronized(self) {
                            DCALAssetItem *dataItem = [[DCALAssetItem alloc] initWithALAsset:asset];
                            SAFE_ARC_AUTORELEASE(dataItem);
                            DCMediaPocketDataItem *mediaPocketDataItem = [[DCMediaPocketDataItem alloc] initWithDataItem:dataItem andUseCount:0];
                            SAFE_ARC_AUTORELEASE(mediaPocketDataItem);
                            
                            [self bottomInsertItem:mediaPocketDataItem];
                            
                            NSInteger result = [self.cameraActionDelegate takePhotoWithDataItem:dataItem.uniqueID];
                            
                            if (result == 0) {
                                [self increaseUseCountForItem:dataItem.uniqueID];
                            }
                        }
                    } while (NO);
                };
                
                void (^failureBlock)(NSError *error) = ^(NSError *error) {
                    dc_debug_NSLog(@"%@", [error localizedDescription]);
                };
                
                [assetsLibrary assetForURL:assetURL resultBlock:assetResultBlock failureBlock:failureBlock];
            }
        }];
    } while (NO);
}

- (DataSourceType)typeForUID:(NSString *)uniqueID {
    DataSourceType result = DataSourceType_Unknown;
    do {
        if (!uniqueID) {
            break;
        }
        if ([uniqueID hasPrefix:kDATAITEMPREFIX_AssetsLib]) {
            result = DataSourceType_AssetsLib;
        }
    } while (NO);
    return result;
}

- (void)insertItem:(NSString *)uniqueID withUseCount:(NSUInteger)useCount {
    do {
        if (!uniqueID) {
            break;
        }
        
        switch ([self typeForUID:uniqueID]) {
            case DataSourceType_AssetsLib:
            {
                ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
                if (!assetsLibrary) {
                    break;
                }
                
//                NSConditionLock *_lock = [[NSConditionLock alloc] initWithCondition:0];
//                SAFE_ARC_AUTORELEASE(_lock);
                
                void (^assetResultBlock)(ALAsset *asset) = ^(ALAsset *asset) {
                    do {
                        if (!asset) {
                            break;
                        }
                        @synchronized(self) {
                            DCALAssetItem *dataItem = [[DCALAssetItem alloc] initWithALAsset:asset];
                            SAFE_ARC_AUTORELEASE(dataItem);
                            DCMediaPocketDataItem *mediaPocketDataItem = [[DCMediaPocketDataItem alloc] initWithDataItem:dataItem andUseCount:useCount];
                            SAFE_ARC_AUTORELEASE(mediaPocketDataItem);
                            
                            [self bottomInsertItem:mediaPocketDataItem];
                        }
                    } while (NO);
//                    if ([_lock tryLockWhenCondition:0]) {
//                        [_lock unlockWithCondition:1];
//                    }
                };
                
                void (^failureBlock)(NSError *error) = ^(NSError *error) {
                    dc_debug_NSLog(@"%@", [error localizedDescription]);
//                    if ([_lock tryLockWhenCondition:0]) {
//                        [_lock unlockWithCondition:1];
//                    }
                };
                
                [assetsLibrary assetForURL:[NSURL URLWithString:uniqueID] resultBlock:assetResultBlock failureBlock:failureBlock];
//                [_lock lockWhenCondition:1];
//                [_lock unlockWithCondition:0];
            }
                break;
                
            case DataSourceType_Facebook:
            {
                [NSException raise:@"ASMediaPocket error" format:@"Not implement yet."];
            }
                break;
                
            default:
                break;
        }
    } while (NO);
}

@end
