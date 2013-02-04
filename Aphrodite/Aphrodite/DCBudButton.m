//
//  DCBudButton.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCBudButton.h"

@implementation DCBudButton

- (id)initWithFrame:(CGRect)frame
{
    @synchronized(self) {
        self = [super initWithFrame:frame];
        if (self) {
            // Initialization code
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
