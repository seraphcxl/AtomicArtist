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
#import "DCMediaPocketSnapshotPool.h"
#import "DCMediaBucket.h"
#import "DCTimelineInterval.h"

NSString * const NOTIFY_MEDIAPOCKET_INSERTED = @"NOTIFY_MEDIAPOCKET_INSERTED";
NSString * const NOTIFY_MEDIAPOCKET_REMOVED = @"NOTIFY_MEDIAPOCKET_REMOVED";
NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME = @"NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME";
NSString * const NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF = @"NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF";

//NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERTED = @"NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERTED";
//NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPREMOVED = @"NOTIFY_MEDIAPOCKET_TIMELINEGROUPREMOVED";

NSString * const NOTIFY_MEDIAPOCKET_GROUPINGDONE = @"NOTIFY_MEDIAPOCKET_GROUPINGDONE";
NSString * const NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERT_DONE = @"NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERT_DONE";

NSString * const kDCMediaPocketSnapshotParam_ItemDict = @"DCMediaPocketSnapshotParam_ItemDict";
NSString * const kDCMediaPocketSnapshotParam_ItemArray = @"DCMediaPocketSnapshotParam_ItemArray";
NSString * const kDCMediaPocketSnapshotParam_TimelineGroupDict = @"DCMediaPocketSnapshotParam_TimelineGroupDict";

static NSUInteger g_uniqueIDNumber = 1;
static DCMediaPocket *sharedDCMediaPocket = nil;

@interface DCMediaPocket () {
    NSMutableArray *_array;  // valve:(id<ASMediaDataItem>)
    NSMutableDictionary *_dict;  // key:(NSString *) valve:(id<ASMediaDataItem>)
    
//    NSMutableDictionary *_timelineGroupDict;  // key:(NSString *) value:(int)
    
    NSMutableArray *_buckets;  // value:(DCMediaBucket *)
}

- (void)clean;

- (DataSourceType)typeForUID:(NSString *)uniqueID;

@end

@implementation DCMediaPocket

@synthesize cameraActionDelegate = _cameraActionDelegate;
@synthesize allowRemoveWhenUseCountIsZero = _allowRemoveWhenUseCountIsZero;
@synthesize uniqueID = _uniqueID;
@synthesize insertingGroupUID = _insertingGroupUID;
@synthesize mediaPocketGrouping = _mediaPocketGrouping;

//DEFINE_SINGLETON_FOR_CLASS(DCMediaPocket);

+ (DCMediaPocket *)sharedDCMediaPocket {
    @synchronized(self) {
        if (sharedDCMediaPocket == nil) {
            sharedDCMediaPocket = [[self alloc] init];
        }
    }
    return sharedDCMediaPocket;
}

+ (void)staticRelease {
    @synchronized(self) {
        SAFE_ARC_SAFERELEASE(sharedDCMediaPocket);
    }
}

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            [self reset];
            _allowRemoveWhenUseCountIsZero = NO;
            self.insertingGroupUID = nil;
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] addAssetsLibUser:self];
            _uniqueID = [NSString stringWithFormat:@"%d", g_uniqueIDNumber++];
            SAFE_ARC_RETAIN(_uniqueID);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _cameraActionDelegate = nil;
            self.insertingGroupUID = nil;
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] removeAssetsLibUser:self];
            
            [self clean];
            
            SAFE_ARC_SAFERELEASE(_uniqueID);
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)clean {
    @synchronized (self) {
        if (_array) {
            [_array removeAllObjects];
            SAFE_ARC_SAFERELEASE(_array);
        }
        
        if (_dict) {
            [_dict removeAllObjects];
            SAFE_ARC_SAFERELEASE(_dict);
        }
        
//        if (_timelineGroupDict) {
//            [_timelineGroupDict removeAllObjects];
//            SAFE_ARC_SAFERELEASE(_timelineGroupDict);
//        }
        
        if (_buckets) {
            [_buckets removeAllObjects];
            SAFE_ARC_SAFERELEASE(_buckets);
        }
    }
}

- (void)reset {
    @synchronized (self) {
        [self clean];
        
        _array = [[NSMutableArray alloc] init];
        
        _dict = [[NSMutableDictionary alloc] init];
        
//        _timelineGroupDict = [[NSMutableDictionary alloc] init];
        
        _buckets = [[NSMutableArray alloc] init];
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
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
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
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
        }
    } while (NO);
    return result;
}

- (void)updateItem:(id<DCMediaPocketDataItemProtocol>)item forUID:(NSString *)uniqueID {
    do {
        if (!item || !uniqueID) {
            break;
        }
        NSMutableArray *notifyArray = [NSMutableArray array];
        @synchronized(self) {
            if (!_array || !_dict) {
                break;
            }
            NSUInteger index = 0;
            for (id<DCMediaPocketDataItemProtocol> oldItem in _array) {
                NSString *oldUID = [oldItem uniqueID];
                if ([oldUID isEqualToString:uniqueID]) {
                    BOOL same = NO;
//                    if ([[oldItem md5] isEqualToString:[item md5]]) {
//                        same = YES;
//                    } else {
//                        same = NO;
//                    }
                    
                    [self removeItemAtIndex:index];
                    [self insertItem:item atIndex:index];
                    
                    NSString *notify = nil;
                    if (same) {
                        notify = NOTIFY_MEDIAPOCKET_UPDATED_MD5SAME;
//                        CheckImageUpdate([uniqueID magString]);
                    } else {
                        notify = NOTIFY_MEDIAPOCKET_UPDATED_MD5DIFF;
//                        CheckImageUpdate([uniqueID magString]);
                    }
                    [notifyArray addObject:uniqueID];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify object:uniqueID];
                    break;
                }
                ++index;
            }
        }
        
        for (NSString *uniqueID in notifyArray) {
//            CheckImageUpdate([uniqueID magString]);
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
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_INSERTED object:[item uniqueID]];
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
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_REMOVED object:uniqueID];
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
//                        CheckImageUpdate([uniqueID magString]);
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

//- (void)insertTimelineGroup:(NSString *)uniqueID {
//    do {
//        if (!uniqueID) {
//            break;
//        }
//        @synchronized(self) {
//            if (!_timelineGroupDict) {
//                break;
//            }
//            
//            [_timelineGroupDict setObject:[NSNumber numberWithInt:1] forKey:uniqueID];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_TIMELINEGROUPINSERTED object:uniqueID];
//    } while (NO);
//}
//
//- (void)removeTimelineGroup:(NSString *)uniqueID {
//    do {
//        if (!uniqueID) {
//            break;
//        }
//        @synchronized(self) {
//            if (!_timelineGroupDict) {
//                break;
//            }
//            
//            [_timelineGroupDict removeObjectForKey:uniqueID];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_TIMELINEGROUPREMOVED object:uniqueID];
//    } while (NO);
//}
//
//- (BOOL)findTimelineGroup:(NSString *)uniqueID {
//    BOOL result = NO;
//    do {
//        if (!uniqueID) {
//            break;
//        }
//        @synchronized(self) {
//            if (!_timelineGroupDict) {
//                break;
//            }
//            
//            if ([_timelineGroupDict objectForKey:uniqueID]) {
//                result = YES;
//            }
//        }
//    } while (NO);
//    return result;
//}
//
//- (NSUInteger)selectedTimelineGroupCount {
//    NSUInteger result = 0;
//    do {
//        @synchronized(self) {
//            if (!_timelineGroupDict) {
//                break;
//            }
//            
//            result = [[_timelineGroupDict allKeys] count];
//        }
//    } while (NO);
//    return result;
//}

- (DCMediaPocket *)snapshot {
    DCMediaPocket *result = nil;
    do {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_array, kDCMediaPocketSnapshotParam_ItemArray, _dict, kDCMediaPocketSnapshotParam_ItemDict, /*_timelineGroupDict*/nil, kDCMediaPocketSnapshotParam_TimelineGroupDict, nil];
        result = [[DCMediaPocket alloc] initByActionSnapshot:params];
        SAFE_ARC_AUTORELEASE(result);
    } while (NO);
    return result;
}

- (id)initByActionSnapshot:(NSDictionary *)params {
    @synchronized(self) {
        self = [super init];
        if (self) {
            [self clean];
            
            _array = [NSMutableArray arrayWithArray:[params objectForKey:kDCMediaPocketSnapshotParam_ItemArray]];
            SAFE_ARC_RETAIN(_array);
            _dict = [NSMutableDictionary dictionaryWithDictionary:[params objectForKey:kDCMediaPocketSnapshotParam_ItemDict]];
            SAFE_ARC_RETAIN(_dict);
//            _timelineGroupDict = [NSMutableDictionary dictionaryWithDictionary:[params objectForKey:kDCMediaPocketSnapshotParam_TimelineGroupDict]];
//            SAFE_ARC_RETAIN(_timelineGroupDict);
            
            _allowRemoveWhenUseCountIsZero = NO;
            [[DCAssetsLibAgent sharedDCAssetsLibAgent] addAssetsLibUser:self];
            _uniqueID = [NSString stringWithFormat:@"%d", g_uniqueIDNumber++];
            SAFE_ARC_RETAIN(_uniqueID);
        }
        return self;
    }
}

- (NSUInteger)bucketCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (!_buckets) {
                break;
            }
            
            result = [_buckets count];
        }
    } while (NO);
    return result;
}

- (DCMediaBucket *)bucket:(NSUInteger)idx {
    DCMediaBucket *result = nil;
    do {
        @synchronized(self) {
            if (!_buckets || idx >= [_buckets count]) {
                break;
            }
            
            result = [_buckets objectAtIndex:idx];
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
        }
    } while (NO);
    return result;
}

- (DCMediaBucket *)bucketIncludeItem:(NSString *)uniqueID {
    DCMediaBucket *result = nil;
    do {
        if (!uniqueID) {
            break;
        }
        @synchronized(self) {
            if (!_buckets) {
                break;
            }
            for (DCMediaBucket *bucket in _buckets) {
                NSInteger idx = [bucket findItem:uniqueID];
                if (idx >= 0 && idx < [bucket itemCount]) {
                    result = bucket;
                    SAFE_ARC_RETAIN(result);
                    SAFE_ARC_AUTORELEASE(result);
                    break;
                }
            }
        }
    } while (NO);
    return result;
}

- (void)grouping {
    dc_debug_NSLog(@"[DCMediaPocket grouping] start.");
    self.mediaPocketGrouping = YES;
    do {
        @synchronized(self) {
            if (_buckets) {
                [_buckets removeAllObjects];
                SAFE_ARC_SAFERELEASE(_buckets);
            }
            _buckets = [NSMutableArray array];
            SAFE_ARC_RETAIN(_buckets);
            
            NSUInteger itemCount = [_array count];
            if (itemCount > DCMediaBucket_Count) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:_array];
                    [sortedArray sortUsingComparator:^(id obj1, id obj2) {
                        NSDate *leftDate = [[obj1 origin] valueForProperty:ALAssetPropertyDate];
                        NSDate *rightDate = [[obj2 origin]  valueForProperty:ALAssetPropertyDate];
                        return [rightDate compare:leftDate];
                    }];
                    // 
                    NSMutableArray *intervalArray = [NSMutableArray array];
                    NSUInteger count = [sortedArray count];
                    for (NSUInteger idx = 0; idx < count - 1; ++idx) {
                        NSTimeInterval left = [[[[sortedArray objectAtIndex:idx] origin] valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                        NSTimeInterval right = [[[[sortedArray objectAtIndex:idx + 1] origin]  valueForProperty:ALAssetPropertyDate] timeIntervalSinceReferenceDate];
                        DCTimelineInterval *interval = [[DCTimelineInterval alloc] init];
                        SAFE_ARC_AUTORELEASE(interval);
                        interval.leftIndex = idx;
                        interval.rightIndex = idx + 1;
                        interval.interval = CFAbsoluteTimeGetDifferenceAsGregorianUnits(left, right, CFTimeZoneCopyDefault(), kCFGregorianAllUnits);
                        [intervalArray addObject:interval];
                    }
                    [intervalArray sortUsingComparator:^(id obj1, id obj2) {
                        return GregorianUnitCompare([obj2 interval], [obj1 interval]);
                        
                    }];
                    //
                    NSRange removeRange;
                    removeRange.location = DCMediaBucket_Count - 1;
                    removeRange.length = [intervalArray count] - (DCMediaBucket_Count - 1);
                    [intervalArray removeObjectsInRange:removeRange];
                    [intervalArray sortUsingComparator:^(id obj1, id obj2) {
                        if ([obj1 leftIndex] > [obj2 leftIndex]) {
                            return (NSComparisonResult)NSOrderedDescending;
                        } else if ([obj1 leftIndex] < [obj2 leftIndex]) {
                            return (NSComparisonResult)NSOrderedAscending;
                        } else {
                            return (NSComparisonResult)NSOrderedSame;
                        }
                        
                    }];
                    //
                    DCMediaBucket *bucket = [[DCMediaBucket alloc] init];
                    SAFE_ARC_AUTORELEASE(bucket);
                    NSUInteger idxForIntervalArray = 0;
                    for (NSUInteger idx = 0; idx < itemCount; ++idx) {
                        BOOL needCreateBucket = NO;
                        id<DCMediaPocketDataItemProtocol> item = [_array objectAtIndex:idx];
                        if (idxForIntervalArray < [intervalArray count] && [[intervalArray objectAtIndex:idxForIntervalArray] leftIndex] == idx) {
                            needCreateBucket = YES;
                            ++idxForIntervalArray;
                        }
                        [bucket insertItemUID:[item uniqueID]];
                        if (needCreateBucket) {
                            [_buckets addObject:bucket];
                            bucket = [[DCMediaBucket alloc] init];
                            SAFE_ARC_AUTORELEASE(bucket);
                        }
                    }
                    [_buckets addObject:bucket];
                    dc_debug_NSLog(@"[DCMediaPocket grouping] end.");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_GROUPINGDONE object:nil];
                });
            } else {
                for (id<DCMediaPocketDataItemProtocol> item in _array) {
                    DCMediaBucket *bucket = [[DCMediaBucket alloc] init];
                    SAFE_ARC_AUTORELEASE(bucket);
                    [_buckets addObject:bucket];
                    [bucket insertItemUID:[item uniqueID]];
                }
                dc_debug_NSLog(@"[DCMediaPocket grouping] end.");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MEDIAPOCKET_GROUPINGDONE object:nil];
            }
        }
    } while (NO);
    self.mediaPocketGrouping = NO;
}

@end
