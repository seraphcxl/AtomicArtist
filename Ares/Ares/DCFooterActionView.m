//
//  DCFooterActionView.m
//  Ares
//
//  Created by Chen XiaoLiang on 13-1-10.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCFooterActionView.h"

@implementation DCFooterActionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame andType:DCPullReleaseViewType_Footer];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dataSourceDidFinishedWorkingWithScrollView:(UIScrollView *)scrollView {
    do {
        [super dataSourceDidFinishedWorkingWithScrollView:scrollView];
        if ([self.delegate respondsToSelector:@selector(relocatePullReleaseView:)]) {
            [self.delegate relocatePullReleaseView:self];
        } else {
            [NSException raise:@"DCFooterActionView error" format:@"delegate should responds to selector relocatePullReleaseView:"];
        }
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
