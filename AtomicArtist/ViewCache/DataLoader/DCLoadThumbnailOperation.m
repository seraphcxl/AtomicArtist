//
//  DCLoadThumbnailOperation.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadThumbnailOperation.h"

NSString * const NOTIFY_THUMBNAILLOADED = @"NOTIFY_THUMBNAILLOADED";

@implementation DCLoadThumbnailOperation

@synthesize thumbnail = _thumbnail;
@synthesize itemUID = _itemUID;

- (void)cancel {
    _canceled = YES;
}

- (id)initWithItemUID:(NSString *)itemUID {
    self = [super init];
    if (self) {
        _canceled = NO;
        _finished = NO;
        _itemUID = itemUID;
        [_itemUID retain];
    }
    return self;
}

- (void)dealloc {
    self.thumbnail = nil;
    
    if (_itemUID) {
        [_itemUID release];
        _itemUID = nil;
    }
    
    [super dealloc];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    if (_finished || _canceled) {
        return YES;
    } else {
        return NO;
    }
}

@end
