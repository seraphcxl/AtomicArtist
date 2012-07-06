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

- (void)actionForBufferFrom:(NSInteger)beginBuffer to:(NSInteger)endBuffer andVisiableFrom:(NSInteger)beginVisiable to:(NSInteger)endVisiable;

- (void)actionForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCurrent:(NSInteger)index;

@end

@implementation DCViewCache

@synthesize delegate = _delegate;
@synthesize lastRequireBufferIndex = _lastRequireBufferIndex;
@synthesize bufferTableCellNumber = _bufferTableCellNumber;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)setBufferTableCellNumber:(NSUInteger)bufferTableCellNumber {
    _bufferTableCellNumber = bufferTableCellNumber;
}

- (void)actionForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCurrent:(NSInteger)index {
    do {
        [self createViewsAndLoadSmallThumbnailForTableCell:index];
        [_queueForVisiableOp cancelAllOperations];
        DCCacheOperationForVisiable *op = [[[DCCacheOperationForVisiable alloc] init] autorelease];
        op.currentTableCellIndex = index;
        op.visiableBeginTableCellIndex = begin;
        op.visiableEndTableCellIndex = end;
        [op setDelegate:self];
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
    [_queueForBufferOp addOperation:op];
}

- (NSArray *)createViewsAndLoadSmallThumbnailForTableCell:(NSUInteger)index {
    NSArray *result = nil;
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
        
        NSArray *existingViewUIDs = [viewsInTableCell allKeys];
        
        // remove view not in addViewUIDs
        for (NSString *uid in existingViewUIDs) {
            if ([addViewUIDs containsObject:uid]) {
                UIView *view = [viewsInTableCell objectForKey:uid];
                if (view) {
                    [self.delegate loadSmallThumbnailForView:view];
                }
                [addViewUIDs removeObject:uid];
            } else {
                [viewsInTableCell removeObjectForKey:uid];
            }
        }
        
        for (NSString *uid in addViewUIDs) {
            UIView *view = [self.delegate createViewWithUID:uid];
            [self.delegate loadSmallThumbnailForView:view];
            [viewsInTableCell setObject:view forKey:uid];
        }
        [_lockForViews unlock];
    } while (NO);
    return result;
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
            visiableEndTableCellIndex = index;
            visiableBeginTableCellIndex = (int)(index + 1 - visiableCellCount) > 0 ? (index + 1 - visiableCellCount) : 0;
        } else if (self.lastRequireBufferIndex < index) {
            visiableBeginTableCellIndex = index;
            visiableEndTableCellIndex = (int)(index + visiableCellCount - 1) > (int)(tableCellCount - 1) ? (tableCellCount - 1) : (index + visiableCellCount - 1);
        } else {
            [NSException raise:@"DCViewCache erroe" format:@"Reason: self.lastRequireBufferIndex == index"];
        }
        
        [self actionForVisiableFrom:visiableBeginTableCellIndex to:visiableEndTableCellIndex andCurrent:index];
        
        if (self.lastRequireBufferIndex == NSUIntegerMax || ABS(self.lastRequireBufferIndex - index) > self.bufferTableCellNumber / 2) {
            if (visiableCellCount < tableCellCount) {
                NSUInteger bufferBeginTableCellIndex = (int)(visiableBeginTableCellIndex - self.bufferTableCellNumber) < 0 ? 0 : visiableBeginTableCellIndex - self.bufferTableCellNumber;
                NSUInteger bufferEndTableCellIndex = visiableEndTableCellIndex + self.bufferTableCellNumber < tableCellCount ? visiableEndTableCellIndex + self.bufferTableCellNumber : tableCellCount;
                
                [self actionForBufferFrom:bufferBeginTableCellIndex to:bufferEndTableCellIndex andVisiableFrom:visiableBeginTableCellIndex to:visiableEndTableCellIndex];
                
                self.lastRequireBufferIndex = index;
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
        self.lastRequireBufferIndex = NSUIntegerMax;
        
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
    }
    return self;
}

- (void)dealloc {
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
- (void)createViewsAndLoadSmallThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForCurrentTableCell:(NSInteger)index andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

#pragma mark DCCacheOperationForBufferDelegate
- (void)createViewsAndLoadSmallThumbnailForBuffer:(NSInteger)beginBuffer to:(NSInteger)endBuffer andVisiable:(NSInteger)beginVisiable to:(NSInteger)endVisiable andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForBuffer:(NSInteger)beginBuffer to:(NSInteger)endBuffer andVisiable:(NSInteger)beginVisiable to:(NSInteger)endVisiable andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)clearCacheWithBufferRangeFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}
@end
