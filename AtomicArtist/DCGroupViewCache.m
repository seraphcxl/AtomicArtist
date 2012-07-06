//
//  DCGroupViewCache.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCGroupViewCache.h"
#import "DCGroupView.h"

@implementation DCGroupViewCache

- (NSString *)uidForView:(UIView *)view {
    NSString *result = nil;
    do {
        if (!view) {
            break;
        }
        if ([view isMemberOfClass:[DCGroupView class]]) {
            DCGroupView *groupView = (DCGroupView *)view;
            result = [groupView dataGroupUID];
        }
    } while (NO);
    return result;
}

@end
