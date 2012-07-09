//
//  DCItemViewCache.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCItemViewCache.h"
#import "DCItemView.h"

@implementation DCItemViewCache

- (NSString *)uidForView:(UIView *)view {
    NSString *result = nil;
    do {
        if (!view) {
            break;
        }
        if ([view isMemberOfClass:[DCItemView class]]) {
            DCItemView *itemView = (DCItemView *)view;
            result = [itemView itemUID];
        }
    } while (NO);
    return result;
}

@end
