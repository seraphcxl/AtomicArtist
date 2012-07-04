//
//  DCViewCacheOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCViewCacheOperation.h"

@implementation DCViewCacheOperation

@synthesize delegate = _delegate;
@synthesize currentTableCellIndex = _currentTableCellIndex;
@synthesize bufferBeginTableCellIndex = _bufferBeginTableCellIndex;
@synthesize bufferEndTableCellIndex = _bufferEndTableCellIndex;
@synthesize visiableBeginTableCellIndex = _visiableBeginTableCellIndex;
@synthesize visiableEndTableCellIndex = _visiableEndTableCellIndex;
@synthesize needClearCache = _needClearCache;

- (id)init {
    self = [super init];
    if (self) {
        self.bufferBeginTableCellIndex = self.visiableBeginTableCellIndex = -1;
        self.visiableEndTableCellIndex = self.bufferEndTableCellIndex = NSUIntegerMax;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {
    _canceled = YES;
}

- (void)main {
    do {
        if (!self.delegate) {
            break;
        }
        
        if (_canceled) {
            break;
        }
        /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
        // clearCache
        if (self.needClearCache) {
            [self.delegate clearCacheWithBufferRangeFrom:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        if (_canceled) {
            NSLog(@"cancel break after clearCache");
            break;
        }
        /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
        // loadBigThumbnailForCurrentTableCell
        [self.delegate loadBigThumbnailForCurrentTableCellWithIndex:self.currentTableCellIndex andCancelFlag:&_canceled];
        if (_canceled) {
            NSLog(@"cancel break after loadBigThumbnailForCurrentTableCell");
            break;
        }
        /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
        // createViewsAndLoadSmallThumbnailForNextBuffer
        if (self.bufferEndTableCellIndex != NSUIntegerMax) {
            [self.delegate createViewsAndLoadSmallThumbnailForNextBufferFrom:self.visiableEndTableCellIndex + 1 to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        if (_canceled) {
            NSLog(@"cancel break after createViewsAndLoadSmallThumbnailForNextBuffer");
            break;
        }
        // createViewsAndLoadSmallThumbnailForPreviousBuffer
        if (self.bufferBeginTableCellIndex != self.visiableBeginTableCellIndex) {
            [self.delegate createViewsAndLoadSmallThumbnailForPreviousBufferFrom:self.bufferBeginTableCellIndex to:self.visiableBeginTableCellIndex - 1 andCancelFlag:&_canceled];
        }
        if (_canceled) {
            NSLog(@"cancel break after createViewsAndLoadSmallThumbnailForPreviousBuffer");
            break;
        }
        /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
        // loadBigThumbnailForVisiableTableCell
        [self.delegate loadBigThumbnailForVisiableTableCellFrom:self.currentTableCellIndex to:self.visiableEndTableCellIndex andCancelFlag:&_canceled];
        if (_canceled) {
            NSLog(@"cancel break after loadBigThumbnailForVisiableTableCell");
            break;
        }
        /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
        // loadBigThumbnailForNextBuffer
        if (self.bufferEndTableCellIndex != NSUIntegerMax) {
            [self.delegate loadBigThumbnailForNextBufferFrom:self.visiableEndTableCellIndex + 1 to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        if (_canceled) {
            NSLog(@"cancel break after loadBigThumbnailForNextBuffer");
            break;
        }
        // loadBigThumbnailForPreviousBuffer
        if (self.bufferBeginTableCellIndex != self.visiableBeginTableCellIndex) {
            [self.delegate loadBigThumbnailForPreviousBufferFrom:self.bufferBeginTableCellIndex to:self.visiableBeginTableCellIndex - 1 andCancelFlag:&_canceled];
        }
        if (_canceled) {
            NSLog(@"cancel break after loadBigThumbnailForPreviousBuffer");
            break;
        }
        
    } while (NO);
}

@end
