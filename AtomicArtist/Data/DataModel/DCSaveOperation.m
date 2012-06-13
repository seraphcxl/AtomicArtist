//
//  DCSaveOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCSaveOperation.h"

@implementation DCSaveOperation

- (void)main {
    NSError *err = nil;
    BOOL successful = [_context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
}

@end
