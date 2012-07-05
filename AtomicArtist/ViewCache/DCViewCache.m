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

- (void)rebuildCache:(NSUInteger)index;

- (void)loadBigThumbnailForCurrentTableCell:(NSInteger)index;

@end

@implementation DCViewCache

@synthesize delegate = _delegate;
@synthesize lastRequireBufferIndex = _lastRequireBufferIndex;
@synthesize bufferTableCellNumber = _bufferTableCellNumber;
@synthesize bufferFrequency = _bufferFrequency;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)setBufferTableCellNumber:(NSUInteger)bufferTableCellNumber {
    _bufferTableCellNumber = bufferTableCellNumber;
    
    if (self.bufferFrequency < bufferTableCellNumber / 2) {
        ;
    } else {
        _bufferFrequency = bufferTableCellNumber / 2;
    }
    
    if (_bufferFrequency < 1) {
        _bufferFrequency = 1;
    }
}

- (void)setBufferFrequency:(NSUInteger)bufferFrequency {
    NSUInteger max = self.bufferTableCellNumber / 2;
    if (bufferFrequency < max) {
        _bufferFrequency = bufferFrequency;
    } else {
        _bufferFrequency = max;
    }
    
    if (_bufferFrequency < 1) {
        _bufferFrequency = 1;
    }
}

- (void)loadBigThumbnailForCurrentTableCell:(NSInteger)index {
}

- (void)rebuildCache:(NSUInteger)index {
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
        [self loadBigThumbnailForCurrentTableCell:index];
        
        if (self.lastRequireBufferIndex == NSUIntegerMax || ABS(self.lastRequireBufferIndex - index) > self.bufferFrequency) {
            [self rebuildCache:index];
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
        
        if (!_queueForCacheOp) {
            _queueForCacheOp = [[NSOperationQueue alloc] init];
            [_queueForCacheOp setMaxConcurrentOperationCount:1];
        }
        
        if (!_queueForLoadCurrentTableCellBigThumbnailOp) {
            _queueForLoadCurrentTableCellBigThumbnailOp = [[NSOperationQueue alloc] init];
            [_queueForLoadCurrentTableCellBigThumbnailOp setMaxConcurrentOperationCount:1];
        }
    }
    return self;
}

- (void)dealloc {
    if (_queueForCacheOp) {
        [_queueForCacheOp cancelAllOperations];
        [_queueForCacheOp waitUntilAllOperationsAreFinished];
        [_queueForCacheOp release];
        _queueForCacheOp = nil;
    }
    
    if (_queueForLoadCurrentTableCellBigThumbnailOp) {
        [_queueForLoadCurrentTableCellBigThumbnailOp cancelAllOperations];
        [_queueForLoadCurrentTableCellBigThumbnailOp waitUntilAllOperationsAreFinished];
        [_queueForLoadCurrentTableCellBigThumbnailOp release];
        _queueForLoadCurrentTableCellBigThumbnailOp = nil;
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

#pragma mark DCViewCacheOperationDelegate
- (void)loadBigThumbnailForVisiableTableCellFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)createViewsAndLoadSmallThumbnailForNextBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)createViewsAndLoadSmallThumbnailForPreviousBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForNextBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
    do {
        if (!cancel) {
            break;
        }
    } while (NO);
}

- (void)loadBigThumbnailForPreviousBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel {
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
