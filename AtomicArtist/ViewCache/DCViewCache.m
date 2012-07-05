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

- (NSString *)uidForView:(UIView *)view;

- (NSString *)uidForTableCell:(NSUInteger)index;

- (void)createViewsAndLoadSmallThumbnailForTableCell:(NSUInteger)index;

- (void)actionForBuffer:(NSUInteger)index;

- (void)actionForVisiable:(NSInteger)index;

@end

@implementation DCViewCache

@synthesize delegate = _delegate;
@synthesize lastRequireBufferIndex = _lastRequireBufferIndex;
@synthesize bufferTableCellNumber = _bufferTableCellNumber;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)setBufferTableCellNumber:(NSUInteger)bufferTableCellNumber {
    _bufferTableCellNumber = bufferTableCellNumber;
}

- (void)actionForVisiable:(NSInteger)index {
}

- (void)actionForBuffer:(NSUInteger)index {
}

- (void)createViewsAndLoadSmallThumbnailForTableCell:(NSUInteger)index {
    do {
        NSString *uidForTableCell = [self uidForTableCell:index];
        [_lockForViews lock];
        NSMutableDictionary *viewsInTableCell = [_tableCells objectForKey:uidForTableCell];
        [_lockForViews unlock];
    } while (NO);
}

- (void)addVisiableTableCell:(NSIndexPath *)indexPath {
    do {
        NSUInteger index = [indexPath row];
        
        [self createViewsAndLoadSmallThumbnailForTableCell:index];
        [self actionForVisiable:index];
        
        if (self.lastRequireBufferIndex == NSUIntegerMax || ABS(self.lastRequireBufferIndex - index) > self.bufferTableCellNumber / 2) {
            [self actionForBuffer:index];
        }
    } while (NO);
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
- (void)createViewsAndLoadSmallThumbnailForBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
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
