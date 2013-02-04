//
//  DCDewView.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCDewView.h"

@implementation DCDewView

@synthesize radius = _radius;
@synthesize anchor = _anchor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _radius = 0.0f;
            _anchor = CGPointZero;
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

+ (NSString *)uniqueIDForRadius:(CGFloat)radius {
    return [NSString stringWithFormat:@"%f", radius];
}

- (NSString *)uniqueID {
    return [NSString stringWithFormat:@"%f", self.radius];
}

- (void)layoutSubviews {
    do {
        ;
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
