//
//  DCCacheOperationForVisiable.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCCacheOperationForVisiable.h"

@implementation DCCacheOperationForVisiable

@synthesize delegate = _delegate;
@synthesize delegateForDCDataLoaderMgr = _delegateForDCDataLoaderMgr;
@synthesize currentTableCellIndex = _currentTableCellIndex;
@synthesize visiableBeginTableCellIndex = _visiableBeginTableCellIndex;
@synthesize visiableEndTableCellIndex = _visiableEndTableCellIndex;

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
        [self.delegateForDCDataLoaderMgr cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
        // loadBigThumbnailForCurrentTableCell
//        if (_canceled) {
//            break;
//        }
//        [self.delegate loadBigThumbnailForCurrentTableCell:self.currentTableCellIndex andCancelFlag:&_canceled];
        // createViewsAndLoadSmallThumbnailForVisiable
//        if (_canceled) {
//            break;
//        }
//        [self.delegate createViewsAndLoadSmallThumbnailForVisiableFrom:self.visiableBeginTableCellIndex to:self.visiableEndTableCellIndex except:self.currentTableCellIndex andCancelFlag:&_canceled];
        // loadBigThumbnailForVisiable
        if (_canceled) {
            break;
        }
        debug_NSLog(@"*** *** *** *** *** *** *** *** *** Visiable: %d to:%d", self.visiableBeginTableCellIndex, self.visiableEndTableCellIndex);
        [self.delegate loadBigThumbnailForVisiableFrom:self.visiableBeginTableCellIndex to:self.visiableEndTableCellIndex except:self.currentTableCellIndex andCancelFlag:&_canceled];
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
