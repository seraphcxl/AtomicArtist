//
//  DCBudButton.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCBudButton.h"

@interface DCBudButton () {
}

- (void)actionForButtonClicked:(id)sender;

@end

@implementation DCBudButton

@synthesize actionDelegate = _actionDelegate;
@synthesize bloomy = _bloomy;

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

- (id)initWithFrame:(CGRect)frame andBloomyState:(BOOL)bloomy {
    @synchronized(self) {
        self = [super initWithFrame:frame];
        if (self) {
            // Initialization code
            _bloomy = bloomy;
            
            [self addTarget:self action:@selector(actionForButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            [self removeTarget:self action:@selector(actionForButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)actionForButtonClicked:(id)sender {
    do {
        @synchronized(self) {
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
