//
//  DCTips.m
//  Whip
//
//  Created by Chen XiaoLiang on 13-3-21.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCTips.h"

@interface DCTips () {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG) UITapGestureRecognizer *tapGR;

- (void)tap:(UITapGestureRecognizer *)tapGR;

@end

@implementation DCTips

@synthesize actionDelegate = _actionDelegate;
@synthesize type = _type;
@synthesize titles = _titles;
@synthesize colorForTitle = _colorForTitle;
@synthesize fontForTitle = _fontForTitle;
@synthesize descriptions = _descriptions;
@synthesize colorForDescription = _colorForDescription;
@synthesize fontForDescription = _fontForDescription;
@synthesize duration = _duration;
@synthesize backgroundColor = _backgroundColor;
@synthesize backgroundImagePath = _backgroundImagePath;
@synthesize anchor = _anchor;
@synthesize radius = _radius;
@synthesize popupOrientation = _popupOrientation;
@synthesize tapGR = _tapGR;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithType:(TipsPopupType)type titles:(NSArray *)titles andDescriptions:(NSArray *)descriptions {
    @synchronized(self) {
        self = [super init];
        if (self) {
            self.type = type;
            self.titles = titles;
            self.descriptions = descriptions;
        }
        return self;
    }
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
