//
//  DCLoadCacheViewBigThumbnailOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadCacheViewBigThumbnailOperation.h"
#import "DCDataLoader.h"

@implementation DCLoadCacheViewBigThumbnailOperation

@synthesize delegate = _delegate;

- (void)cancel {
    _canceled = TRUE;
}

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
        [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
        // loadBigThumbnailForCacheViews
        if (_canceled) {
            break;
        }
        [self.delegate loadBigThumbnailForCacheViewsCancelFlag:&_canceled];
    } while (NO);

}
@end
