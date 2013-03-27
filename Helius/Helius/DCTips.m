//
//  DCTips.m
//  Helius
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
@synthesize descriptions = _descriptions;
@synthesize colorForDescription = _colorForDescription;
@synthesize fontForDescription = _fontForDescription;
@synthesize duration = _duration;
@synthesize showBackground = _showBackground;
@synthesize backgroundColor = _backgroundColor;
@synthesize backgroundImagePath = _backgroundImagePath;
@synthesize backgrondImage = _backgrondImage;
@synthesize triangleHeight = _triangleHeight;
@synthesize angle = _angle;
@synthesize centerAnchor = _centerAnchor;
@synthesize popupAnchor = _popupAnchor;
@synthesize popupRadius = _popupRadius;
@synthesize popupOrientation = _popupOrientation;
@synthesize tapGR = _tapGR;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        _descriptions = nil;
        self.colorForDescription = TIPS_DESCROPTIONCOLOR;
        self.fontForDescription = [UIFont systemFontOfSize:TIPS_DESCROPTIONFONTSIZE];
        
        self.duration = TIPS_DURATION_SEC;
        self.backgroundColor = TIPS_DEFBACKGROUNDCOLOR;
        _backgroundImagePath = nil;
        _backgrondImage = nil;
        
        self.triangleHeight = 0.0f;
        
        self.angle = 0;
        
        self.centerAnchor = CGPointZero;
        self.center = self.centerAnchor;
        
        self.popupAnchor = CGPointZero;
        self.popupRadius = 0.0f;
        self.popupOrientation = TPO_Top;
        
        UITapGestureRecognizer *tapGRForHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGR = tapGRForHide;
        self.tapGR.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.tapGR];
        SAFE_ARC_AUTORELEASE(tapGRForHide);
    }
    return self;
}

- (id)initWithType:(TipsPopupType)type descriptions:(NSArray *)descriptions {
    @synchronized(self) {
        self = [self initWithFrame:CGRectZero];
        if (self) {
            SAFE_ARC_RETAIN(descriptions);
            SAFE_ARC_SAFERELEASE(_descriptions);
            _descriptions = [descriptions copy];
            SAFE_ARC_RELEASE(descriptions);
        }
        return self;
    }
}

- (id)initWithType:(TipsPopupType)type image:(UIImage *)image {
    @synchronized(self) {
        self = [self initWithFrame:CGRectZero];
        if (self) {
            SAFE_ARC_RETAIN(image);
            SAFE_ARC_SAFERELEASE(_backgrondImage);
            _backgrondImage = image;
        }
        return self;
    }
}

- (id)initWithType:(TipsPopupType)type imagePath:(NSString *)imagePath {
    @synchronized(self) {
        self = [self initWithFrame:CGRectZero];
        if (self) {
            SAFE_ARC_RETAIN(imagePath);
            SAFE_ARC_SAFERELEASE(_backgroundImagePath);
            _backgroundImagePath = [imagePath copy];
            SAFE_ARC_RELEASE(imagePath);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (self.tapGR) {
                [self removeGestureRecognizer:self.tapGR];
                self.tapGR = nil;
            }
            
            SAFE_ARC_SAFERELEASE(_backgrondImage);
            SAFE_ARC_SAFERELEASE(_backgroundImagePath);
            self.backgroundColor = nil;

            self.fontForDescription = nil;
            self.colorForDescription = nil;
            SAFE_ARC_SAFERELEASE(_descriptions);
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)tap:(UITapGestureRecognizer *)tapGR {
    do {
        if (tapGR != self.tapGR) {
            break;
        }
    } while (NO);
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
