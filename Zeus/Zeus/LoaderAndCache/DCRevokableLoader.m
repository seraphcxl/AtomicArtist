//
//  DCRevokableLoader.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCRevokableLoader.h"

@implementation DCRevokableLoader

@synthesize revoke = _revoke;

- (void)cancel {
    do {
        self.revoke = YES;
    } while (NO);
}

@end
