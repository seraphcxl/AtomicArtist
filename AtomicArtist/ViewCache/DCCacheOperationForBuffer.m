//
//  DCCacheOperationForBuffer.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCCacheOperationForBuffer.h"

@implementation DCCacheOperationForBuffer

@synthesize delegate = _delegate;
@synthesize delegateForDCDataLoaderMgr = _delegateForDCDataLoaderMgr;
@synthesize bufferBeginTableCellIndex = _bufferBeginTableCellIndex;
@synthesize bufferEndTableCellIndex = _bufferEndTableCellIndex;
@synthesize visiableBeginTableCellIndex = _visiableBeginTableCellIndex;
@synthesize visiableEndTableCellIndex = _visiableEndTableCellIndex;
@synthesize needClearCache = _needClearCache;

- (void)cancel {
    _canceled = TRUE;
}

- (id)init {
    self = [super init];
    if (self) {
        _canceled = NO;
        _finished = NO;
    }
    return self;
}

- (void)main {
    do {
        if (!self.delegate || !self.delegateForDCDataLoaderMgr) {
            break;
        }
        // createViewsAndLoadSmallThumbnailForBuffer
        if (_canceled) {
            break;
        }
        if (self.needClearCache) {
            [self.delegate clearCacheWithBufferRangeFrom:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        // perpare indexs
        if (_canceled) {
            break;
        }
        
        NSMutableArray *prevIndexs = [[[NSMutableArray alloc] init] autorelease];
        for (NSInteger index = self.visiableBeginTableCellIndex - 1; index >= self.bufferBeginTableCellIndex; --index) {
            NSString *indexStr = [[[NSString alloc] initWithFormat:@"%d", index] autorelease];
            [prevIndexs addObject:indexStr];
        }
        
        NSMutableArray *nextIndexs = [[[NSMutableArray alloc] init] autorelease];
        for (NSInteger index = self.visiableEndTableCellIndex + 1; index <= self.bufferEndTableCellIndex; ++index) {
            NSString *indexStr = [[[NSString alloc] initWithFormat:@"%d", index] autorelease];
            [nextIndexs addObject:indexStr];
        }
        // createViewsAndLoadSmallThumbnailForBuffer
        if (_canceled) {
            break;
        }
        
        [self.delegate createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:prevIndexs nextIndexs:nextIndexs andCancelFlag:&_canceled];
        // loadBigThumbnailForBuffer
        if (_canceled) {
            break;
        }
        [self.delegateForDCDataLoaderMgr cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        [self.delegate loadBigThumbnailForBufferWithPrevIndexs:prevIndexs nextIndexs:nextIndexs andCancelFlag:&_canceled];
        _finished = YES;
    } while (NO);
}

- (BOOL)isConcurrent {
    return NO;
}

- (BOOL)isFinished {
    if (_finished || _canceled) {
        return YES;
    } else {
        return NO;
    }
}

@end
