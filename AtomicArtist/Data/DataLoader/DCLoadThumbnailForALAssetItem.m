//
//  DCLoadThumbnailForALAssetItem.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadThumbnailForALAssetItem.h"

@implementation DCLoadThumbnailForALAssetItem

@synthesize delegate = _delegate;
@synthesize dataItem = _dataItem;

- (void)main {
    NSLog(@"DCLoadThumbnailForALAssetItem main enter");
    do {
        if (!self.dataItem) {
            break;
        }
    } while (NO);
    NSLog(@"DCLoadThumbnailForALAssetItem main exit");
}

- (id)initWithDataItem:(id <DCDataItem>)dataItem {
    self = [super init];
    if (self) {
        self.dataItem = dataItem;
    }
    return self;
}

- (void)dealloc {
    self.dataItem = nil;
    
    [super dealloc];
}

@end
