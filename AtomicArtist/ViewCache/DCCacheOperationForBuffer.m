//
//  DCCacheOperationForBuffer.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCCacheOperationForBuffer.h"
#import "DCDataLoader.h"

@implementation DCCacheOperationForBuffer

@synthesize delegate = _delegate;
@synthesize bufferBeginTableCellIndex = _bufferBeginTableCellIndex;
@synthesize bufferEndTableCellIndex = _bufferEndTableCellIndex;
@synthesize visiableBeginTableCellIndex = _visiableBeginTableCellIndex;
@synthesize visiableEndTableCellIndex = _visiableEndTableCellIndex;
@synthesize needClearCache = _needClearCache;

- (id)init {
    self = [super init];
    if (self) {
        _canceled = NO;
    }
    return self;
}

- (void)main {
    do {
        if (!self.delegate) {
            break;
        }
        // createViewsAndLoadSmallThumbnailForBuffer
        if (_canceled) {
            break;
        }
        if (self.needClearCache) {
            [self.delegate clearCacheWithBufferRangeFrom:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        // createViewsAndLoadSmallThumbnailForBuffer
        if (_canceled) {
            break;
        }
        [self.delegate createViewsAndLoadSmallThumbnailForBuffer:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andVisiable:self.visiableBeginTableCellIndex to:self.visiableEndTableCellIndex andCancelFlag:&_canceled];
        // loadBigThumbnailForBuffer
        if (_canceled) {
            break;
        }
        [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        [self.delegate loadBigThumbnailForBuffer:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andVisiable:self.visiableBeginTableCellIndex to:self.visiableEndTableCellIndex andCancelFlag:&_canceled];
    } while (NO);
}

@end
