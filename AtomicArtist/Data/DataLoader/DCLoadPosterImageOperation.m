//
//  DCLoadPosterImageOperation.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadPosterImageOperation.h"

NSString * const NOTIFY_POSTERIMAGELOADEDFORALASSETSGROUP = @"NOTIFY_POSTERIMAGELOADEDFORALASSETSGROUP";

@implementation DCLoadPosterImageOperation

@synthesize dataGroupUID = _dataGroupUID;

- (id)initWithItemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID {
    self = [super initWithItemUID:itemUID];
    if (self) {
        _dataGroupUID = dataGroupUID;
        [_dataGroupUID retain];
    }
    return self;
}

- (void)dealloc {
    if (_dataGroupUID) {
        [_dataGroupUID release];
        _dataGroupUID = nil;
    }
    
    [super dealloc];
}

@end
