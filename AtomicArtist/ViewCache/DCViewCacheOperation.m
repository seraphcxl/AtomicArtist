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
        // clear cache
        if (self.needClearCache) {
            [self.delegate actionForClearCacheWithBufferRangeFrom:self.bufferBeginTableCellIndex to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        
        if (_canceled) {
            break;
        }
        // do action for current cell
        [self.delegate actionForCurrentTableCellWithIndex:self.currentTableCellIndex andCancelFlag:&_canceled];
        
        if (_canceled) {
            break;
        }
        // do action for visiable range
        [self.delegate actionForVisiableTableCellFrom:self.currentTableCellIndex to:self.visiableEndTableCellIndex andCancelFlag:&_canceled];
        
        if (_canceled) {
            break;
        }
        // do action for next buffer
        if (self.bufferEndTableCellIndex != NSUIntegerMax) {
            [self.delegate actionForNextBufferFrom:self.visiableEndTableCellIndex + 1 to:self.bufferEndTableCellIndex andCancelFlag:&_canceled];
        }
        
        if (_canceled) {
            break;
        }
        // do action for prev buffer
        if (self.bufferBeginTableCellIndex != self.visiableBeginTableCellIndex) {
            [self.delegate actionForPreviousBufferFrom:self.bufferBeginTableCellIndex to:self.visiableBeginTableCellIndex - 1 andCancelFlag:&_canceled];
        }
    } while (NO);
}

@end
