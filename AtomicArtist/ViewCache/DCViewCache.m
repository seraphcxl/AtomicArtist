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

- (void)addVisiableTableCell:(NSIndexPath *)indexPath {
}

- (UIView *)getViewWithUID:(NSString *)uid {
    UIView *result = nil;
    do {
        if (_views) {
            result = [_views objectForKey:uid];
        }
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
        if (!_views) {
            _views = [[NSMutableDictionary alloc] init];
        }
        
        if (!_tableCells) {
            _tableCells = [[NSMutableDictionary alloc] init];
        }
        
        if (!_operationQueue) {
            _operationQueue = [[NSOperationQueue alloc] init];
            [_operationQueue setMaxConcurrentOperationCount:1];
        }
        
        if (!_lockForViews) {
            _lockForViews = [[NSLock alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
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
    
    if (_lockForViews) {
        [_lockForViews release];
        _lockForViews = nil;
    }
    
    [super dealloc];
}

@end
