//
//  DCViewCache.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCViewCache.h"

@interface DCViewCache () {

}

- (NSString *)uidForTableCell:(NSUInteger)index;

- (NSArray *)createViewsAndLoadSmallThumbnailForTableCell:(NSUInteger)index;

- (void)loadBigThumbnailInQueue:(enum DATALODER_TYPE)type forTableCell:(NSInteger)index andCancelFlag:(BOOL *)cancel;

- (void)clearCacheWithBufferForTableCell:(NSInteger)index;

- (void)actionForBufferFrom:(NSInteger)beginBuffer to:(NSInteger)endBuffer andVisiableFrom:(NSInteger)beginVisiable to:(NSInteger)endVisiable;

- (void)actionForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCurrent:(NSInteger)index;

@end

@implementation DCViewCache

@synthesize delegate = _delegate;
@synthesize lastRequireBufferIndex = _lastRequireBufferIndex;
@synthesize bufferTableCellNumber = _bufferTableCellNumber;
@synthesize dataLoader = _dataLoader;
//@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)loadBigThumbnailForCacheViews {
    do {
        [_queueForVisiableOp cancelAllOperations];
        DCLoadCacheViewBigThumbnailOperation *op = [[[DCLoadCacheViewBigThumbnailOperation alloc] init] autorelease];
        [op setDelegate:self];
        [op setDelegateForDCDataLoaderMgr:self];
        [_queueForVisiableOp addOperation:op];
    } while (NO);
}

- (void)actionForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCurrent:(NSInteger)index {
    do {
        debug_NSLog(@"*** *** *** *** *** *** Add visiable op for from: %d to:%d current:%d", begin, end, index);
        [self createViewsAndLoadSmallThumbnailForTableCell:index];
        [_queueForVisiableOp cancelAllOperations];
        DCCacheOperationForVisiable *op = [[[DCCacheOperationForVisiable alloc] init] autorelease];
        op.currentTableCellIndex = index;
        op.visiableBeginTableCellIndex = begin;
        op.visiableEndTableCellIndex = end;
        [op setDelegate:self];
        [op setDelegateForDCDataLoaderMgr:self];
        [_queueForVisiableOp addOperation:op];
    } while (NO);
}

- (void)actionForBufferFrom:(NSInteger)beginBuffer to:(NSInteger)endBuffer andVisiableFrom:(NSInteger)beginVisiable to:(NSInteger)endVisiable {
    [_queueForBufferOp cancelAllOperations];
    DCCacheOperationForBuffer *op = [[[DCCacheOperationForBuffer alloc] init] autorelease];
    op.visiableBeginTableCellIndex = beginVisiable;
    op.visiableEndTableCellIndex = endVisiable;
    op.bufferBeginTableCellIndex = beginBuffer;
    op.bufferEndTableCellIndex = endBuffer;
    [op setDelegate:self];
    [op setDelegateForDCDataLoaderMgr:self];
    [_queueForBufferOp addOperation:op];
}

- (NSArray *)createViewsAndLoadSmallThumbnailForTableCell:(NSUInteger)index {
    NSMutableArray *result = nil;
    do {
        if (!self.delegate) {
            break;
        }
        NSString *uidForTableCell = [self uidForTableCell:index];
        [_lockForViews lock];
        NSMutableDictionary *viewsInTableCell = [_tableCells objectForKey:uidForTableCell];
        
        if (!viewsInTableCell) {
            viewsInTableCell = [[[NSMutableDictionary alloc] init] autorelease];
            [_tableCells setObject:viewsInTableCell forKey:uidForTableCell];
        }
        
        NSMutableArray *addViewUIDs = [self.delegate getViewUIDsForTableCellAtIndexPath:index];
        
        NSMutableArray *existingViewUIDs = [[[NSMutableArray alloc] initWithArray:[viewsInTableCell allKeys]] autorelease];
        
        result = [[[NSMutableArray alloc] init] autorelease];
        
        for (NSString *uid in addViewUIDs) {
            UIView *view = nil;
            if ([existingViewUIDs containsObject:uid]) {
                view = [viewsInTableCell objectForKey:uid];
                if (view) {
                    [self.delegate loadSmallThumbnailForView:view];
                }
                [existingViewUIDs removeObject:uid];
            } else {
                view = [self.delegate createViewWithUID:uid];
                [self.delegate loadSmallThumbnailForView:view];
                [viewsInTableCell setObject:view forKey:uid];
                [_views setObject:view forKey:uid];
            }
            
            if (view) {
                [result addObject:view];
            }
        }
        
        for (NSString *uid in existingViewUIDs) {
            [viewsInTableCell removeObjectForKey:uid];
        }
        
        [_lockForViews unlock];
    } while (NO);
    return result;
}

- (void)loadBigThumbnailInQueue:(enum DATALODER_TYPE)type forTableCell:(NSInteger)index andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        
        NSString *uidForTableCell = [self uidForTableCell:index];
        NSArray *allViews = nil;
        [_lockForViews lock];
        NSMutableDictionary *viewsInTableCell = [_tableCells objectForKey:uidForTableCell];
        if (viewsInTableCell) {
            allViews = [viewsInTableCell allValues];
        }
        [_lockForViews unlock];
        
        for (UIView *view in allViews) {
            if (*cancel) {
                debug_NSLog(@"Cancel from loadBigThumbnailForTableCell:andCancelFlag:");
                break;
            }
            [self.delegate loadBigThumbnailInQueue:type forView:view];
        }
        
        if (*cancel) {
            debug_NSLog(@"Cancel from loadBigThumbnailForTableCell:andCancelFlag:");
            break;
        }

    } while (NO);
}

- (void)clearCacheWithBufferForTableCell:(NSInteger)index {
    do {
        [_lockForViews lock];
        NSString *uidForTableCell = [self uidForTableCell:index];
        NSArray *allViews = nil;
        NSMutableDictionary *viewsInTableCell = [_tableCells objectForKey:uidForTableCell];
        if (viewsInTableCell) {
            allViews = [viewsInTableCell allValues];
        }
        
        for (UIView *view in allViews) {
            NSString *viewUID = [self uidForView:view];
            [_views removeObjectForKey:viewUID];
        }
        
        [_tableCells removeObjectForKey:uidForTableCell];
        
        [_lockForViews unlock];
    } while (NO);
}

- (NSArray *)getViewsForTableCell:(NSIndexPath *)indexPath {
    NSArray *result = nil;
    do {
        if (!self.delegate) {
            break;
        }
        NSUInteger index = [indexPath row];
        NSUInteger visiableBeginTableCellIndex = 0;
        NSUInteger visiableEndTableCellIndex = NSUIntegerMax;
        
        NSUInteger visiableCellCount = [self.delegate visiableCellCount];
        NSUInteger tableCellCount = [self.delegate tableCellCount];
        
        result = [self createViewsAndLoadSmallThumbnailForTableCell:index];
        
        if (self.lastRequireBufferIndex > index) {
            visiableBeginTableCellIndex = index;
            visiableEndTableCellIndex = (int)(index + visiableCellCount) > (int)(tableCellCount - 1) ? (tableCellCount - 1) : (index + visiableCellCount);
        } else if (self.lastRequireBufferIndex == 0 || self.lastRequireBufferIndex < index) {
            visiableEndTableCellIndex = index;
            visiableBeginTableCellIndex = (int)(index + 1 - visiableCellCount) - 1 >= 0 ? (index + 1 - visiableCellCount) - 1 : 0;
        } else {
            break;
        }
        
        [self actionForVisiableFrom:visiableBeginTableCellIndex to:visiableEndTableCellIndex andCurrent:index];
        
        if (self.lastRequireBufferIndex == 0 || ABS(self.lastRequireBufferIndex - index) > self.bufferTableCellNumber / 2) {
            if (visiableCellCount < tableCellCount) {
                NSUInteger bufferBeginTableCellIndex = (int)(visiableBeginTableCellIndex - self.bufferTableCellNumber) < 0 ? 0 : visiableBeginTableCellIndex - self.bufferTableCellNumber;
                NSUInteger bufferEndTableCellIndex = visiableEndTableCellIndex + self.bufferTableCellNumber < (tableCellCount - 1) ? visiableEndTableCellIndex + self.bufferTableCellNumber : (tableCellCount - 1);
                
                [self actionForBufferFrom:bufferBeginTableCellIndex to:bufferEndTableCellIndex andVisiableFrom:visiableBeginTableCellIndex to:visiableEndTableCellIndex];
                
                _lastRequireBufferIndex = index;
            }
        }
    } while (NO);
    return result;
}

- (UIView *)getViewWithUID:(NSString *)uid {
    UIView *result = nil;
    do {
        [_lockForViews lock];
        if (_views) {
            result = [_views objectForKey:uid];
        }
        [_lockForViews unlock];
    } while (NO);
    return result;
}

- (NSString *)uidForTableCell:(NSUInteger)index {
    return [[[NSString alloc] initWithFormat:@"%d", index] autorelease];
}

- (NSString *)uidForView:(UIView *)view {
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        _lastRequireBufferIndex = 0;
        
        if (!_lockForViews) {
            _lockForViews = [[NSLock alloc] init];
        }
        
        [_lockForViews lock];
        if (!_views) {
            _views = [[NSMutableDictionary alloc] init];
        }
        
        if (!_tableCells) {
            _tableCells = [[NSMutableDictionary alloc] init];
        }
        [_lockForViews unlock];
        
        if (!_queueForVisiableOp) {
            _queueForVisiableOp = [[NSOperationQueue alloc] init];
            [_queueForVisiableOp setMaxConcurrentOperationCount:1];
        }
        
        if (!_queueForBufferOp) {
            _queueForBufferOp = [[NSOperationQueue alloc] init];
            [_queueForBufferOp setMaxConcurrentOperationCount:1];
        }
        
        if (!_dataLoader) {
            _dataLoader = [[DCDataLoader alloc] init];
        }
    }
    return self;
}

- (void)clearOperations {
    if (_queueForVisiableOp) {
        [_queueForVisiableOp cancelAllOperations];
        [_queueForVisiableOp waitUntilAllOperationsAreFinished];
    }
    
    if (_queueForBufferOp) {
        [_queueForBufferOp cancelAllOperations];
        [_queueForBufferOp waitUntilAllOperationsAreFinished];
    }
}

- (void)clear {
    [self clearOperations];
    
    [_lockForViews lock];
    if (_tableCells) {
        [_tableCells removeAllObjects];
    }
    
    if (_views) {
        [_views removeAllObjects];
    }
    [_lockForViews unlock];
}

- (void)dealloc {
    if (_dataLoader) {
        [_dataLoader release];
        _dataLoader = nil;
    }
    
    if (_queueForVisiableOp) {
        [_queueForVisiableOp cancelAllOperations];
        [_queueForVisiableOp waitUntilAllOperationsAreFinished];
        [_queueForVisiableOp release];
        _queueForVisiableOp = nil;
    }
    
    if (_queueForBufferOp) {
        [_queueForBufferOp cancelAllOperations];
        [_queueForBufferOp waitUntilAllOperationsAreFinished];
        [_queueForBufferOp release];
        _queueForBufferOp = nil;
    }
    
    [_lockForViews lock];
    if (_tableCells) {
        [_tableCells removeAllObjects];
        [_tableCells release];
        _tableCells = nil;
    }
    
    if (_views) {
        [_views removeAllObjects];
        [_views release];
        _views = nil;
    }
    [_lockForViews unlock];
    
    if (_lockForViews) {
        [_lockForViews release];
        _lockForViews = nil;
    }
    
    [super dealloc];
}

#pragma mark DCCacheOperationForVisiableDelegate
- (void)createViewsAndLoadSmallThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end except:(NSInteger)current andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        for (NSUInteger index = begin; index <= end; ++index) {
            if (*cancel) {
                debug_NSLog(@"Cancel from createViewsAndLoadSmallThumbnailForVisiableFrom:to:except:andCancelFlag:");
                break;
            }
            if (index != current) {
                [self createViewsAndLoadSmallThumbnailForTableCell:index];
            }
        }
    } while (NO);
}

- (void)loadBigThumbnailForCurrentTableCell:(NSInteger)index andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        [self loadBigThumbnailInQueue:DATALODER_TYPE_VISIABLE forTableCell:index andCancelFlag:cancel];
    } while (NO);
}

- (void)loadBigThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end except:(NSInteger)current andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        for (NSUInteger index = begin; index <= end; ++index) {
            if (*cancel) {
                debug_NSLog(@"Cancel from loadBigThumbnailForVisiableFrom:to:except:andCancelFlag:");
                break;
            }
            [self loadBigThumbnailInQueue:DATALODER_TYPE_VISIABLE forTableCell:index andCancelFlag:cancel];
//            if (index != current) {
//                [self loadBigThumbnailInQueue:DATALODER_TYPE_VISIABLE forTableCell:index andCancelFlag:cancel];
//            }
        }
        
        if (*cancel) {
            debug_NSLog(@"Cancel from loadBigThumbnailForVisiableFrom:to:except:andCancelFlag:");
            break;
        }
    } while (NO);
}

#pragma mark DCCacheOperationForBufferDelegate
- (void)createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:(NSArray *)prevIndexs nextIndexs:(NSArray *)nextIndexs andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel || !prevIndexs || !nextIndexs) {
            break;
        }
        NSUInteger prevIndexsCount = [prevIndexs count];
        NSUInteger nextIndexsCount = [nextIndexs count];
        NSUInteger count = MAX(prevIndexsCount, nextIndexsCount);
        
        for (NSUInteger index = 0; index < count; ++index) {
            if (*cancel) {
                debug_NSLog(@"Cancel from createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
                break;
            }
            if (index < nextIndexsCount) {
                NSString *nextIndexStr = [nextIndexs objectAtIndex:index];
                if (nextIndexStr) {
                    NSUInteger nextIndex = [nextIndexStr integerValue];
                    [self createViewsAndLoadSmallThumbnailForTableCell:nextIndex];
                }
            }
            
            if (*cancel) {
                debug_NSLog(@"Cancel from createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
                break;
            }
            if (index < prevIndexsCount) {
                NSString *prevIndexStr = [prevIndexs objectAtIndex:index];
                if (prevIndexStr) {
                    NSUInteger prevIndex = [prevIndexStr integerValue];
                    [self createViewsAndLoadSmallThumbnailForTableCell:prevIndex];
                }
            }
        }
        
        if (*cancel) {
            debug_NSLog(@"Cancel from createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForBufferWithPrevIndexs:(NSArray *)prevIndexs nextIndexs:(NSArray *)nextIndexs andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel || !prevIndexs || !nextIndexs) {
            break;
        }
        NSUInteger prevIndexsCount = [prevIndexs count];
        NSUInteger nextIndexsCount = [nextIndexs count];
        NSUInteger count = MAX(prevIndexsCount, nextIndexsCount);
        
        for (NSUInteger index = 0; index < count; ++index) {
            if (*cancel) {
                debug_NSLog(@"Cancel from loadBigThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
                break;
            }
            if (index < nextIndexsCount) {
                NSString *nextIndexStr = [nextIndexs objectAtIndex:index];
                if (nextIndexStr) {
                    NSUInteger nextIndex = [nextIndexStr integerValue];
                    [self loadBigThumbnailInQueue:DATALODER_TYPE_BUFFER forTableCell:nextIndex andCancelFlag:cancel];
                }
            }
            
            if (*cancel) {
                debug_NSLog(@"Cancel from loadBigThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
                break;
            }
            if (index < prevIndexsCount) {
                NSString *prevIndexStr = [prevIndexs objectAtIndex:index];
                if (prevIndexStr) {
                    NSUInteger prevIndex = [prevIndexStr integerValue];
                    [self loadBigThumbnailInQueue:DATALODER_TYPE_BUFFER forTableCell:prevIndex andCancelFlag:cancel];
                }
            }
        }
        
        if (*cancel) {
            debug_NSLog(@"Cancel from loadBigThumbnailForBufferWithPrevIndexs:nextIndexs:andCancelFlag:");
            break;
        }
    } while (NO);
}

- (void)clearCacheWithBufferRangeFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        [_lockForViews lock];
        NSArray *allTableCellIndexs = [_tableCells allKeys];
        [_lockForViews unlock];
        
        for (NSString *tableCellIndexStr in allTableCellIndexs) {
            if (*cancel) {
                debug_NSLog(@"Cancel from clearCacheWithBufferRangeFrom:to:andCancelFlag:");
                break;
            }
            
            if (tableCellIndexStr) {
                NSUInteger tableCellIndex = [tableCellIndexStr integerValue];
                if (tableCellIndex <= begin || tableCellIndex >= end) {
                    [self clearCacheWithBufferForTableCell:tableCellIndex];
                }
            }
        }
        if (*cancel) {
            debug_NSLog(@"Cancel from clearCacheWithBufferRangeFrom:to:andCancelFlag:");
            break;
        }
    } while (NO);
}

#pragma mark DCLoadCacheViewBigThumbnailOperationDelegate
- (void)loadBigThumbnailForCacheViewsCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
        [_lockForViews lock];
        NSArray *allTableCellIndexs = [_tableCells allKeys];
        [_lockForViews unlock];
        
        for (NSString *tableCellIndexStr in allTableCellIndexs) {
            if (*cancel) {
                debug_NSLog(@"Cancel from clearCacheWithBufferRangeFrom:to:andCancelFlag:");
                break;
            }
            
            if (tableCellIndexStr) {
                NSUInteger tableCellIndex = [tableCellIndexStr integerValue];
                [self loadBigThumbnailInQueue:DATALODER_TYPE_VISIABLE forTableCell:tableCellIndex andCancelFlag:cancel];
            }
        }

    } while (NO);
}

#pragma mark DCDataLoaderMgrDelegate
- (void)queue:(enum DATALODER_TYPE)type addOperation:(NSOperation *)operation {
    do {
        if (self.dataLoader) {
            [self.dataLoader queue:type addOperation:operation];
        }
    } while (NO);
}

- (void)cancelAllOperationsOnQueue:(enum DATALODER_TYPE)type {
    do {
        if (self.dataLoader) {
            [self.dataLoader cancelAllOperationsOnQueue:type];
        }
    } while (NO);
}

- (void)terminateAllOperationsOnQueue:(enum DATALODER_TYPE)type {
    do {
        if (self.dataLoader) {
            [self.dataLoader terminateAllOperationsOnQueue:type];
        }
    } while (NO);
}

- (void)queue:(enum DATALODER_TYPE)type pauseWithAutoResume:(BOOL)enable with:(NSTimeInterval)seconds {
    do {
        if (self.dataLoader) {
            [self.dataLoader queue:type pauseWithAutoResume:enable with:seconds];
        }
    } while (NO);
}

@end
