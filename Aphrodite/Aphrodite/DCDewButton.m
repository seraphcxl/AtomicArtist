//
//  DCDewButton.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCDewButton.h"

@implementation DCDewButton

@synthesize radius = _radius;
@synthesize anchorDelegate = _anchorDelegate;
@synthesize angleDelegate = _angleDelegate;

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
            _angleDelegate = nil;
            _anchorDelegate = nil;
            _radius = 0.0f;
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
