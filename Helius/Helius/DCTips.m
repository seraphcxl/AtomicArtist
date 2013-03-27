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
@property (nonatomic, assign) CGSize recommendLabelSize;
@property (nonatomic, assign) CGSize descLabelsSize;

- (void)tap:(UITapGestureRecognizer *)tapGR;

- (void)layoutSubviewsForCenter;
- (void)layoutSubviewsForCenterAncher;
- (void)layoutSubviewsForPopup;

- (NSArray *)prepareDescriptionLabels;

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
@synthesize recommendLabelSize = _recommendLabelSize;
@synthesize descLabelsSize = _descLabelsSize;

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

- (id)initWithType:(TipsPopupType)type descriptions:(NSArray *)descriptions andRecommendSize:(CGSize)size {
    @synchronized(self) {
        self = [self initWithFrame:CGRectZero];
        if (self) {
            SAFE_ARC_RETAIN(descriptions);
            SAFE_ARC_SAFERELEASE(_descriptions);
            _descriptions = [descriptions copy];
            SAFE_ARC_RELEASE(descriptions);
            
            self.recommendLabelSize = size;
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
        if (self.actionDelegate) {
            [self.actionDelegate disdmissTips:self];
        }
    } while (NO);
}

- (void)layoutSubviews {
    do {
        switch (self.type) {
            case TPT_Center:
            {
                [self layoutSubviewsForCenter];
            }
                break;
            case TPT_CustomLocation_CenterAncher:
            {
                [self layoutSubviewsForCenterAncher];
            }
                break;
            case TPT_CustomLocation_Popup:
            {
                [self layoutSubviewsForPopup];
            }
                break;
                
            default:
                break;
        }
    } while (NO);
}

- (NSArray *)prepareDescriptionLabels {
    NSMutableArray *result = nil;
    do {
        NSUInteger space = TIPS_INNERSPACE;
        NSUInteger width = TIPS_DEF_WIDTH;
        NSUInteger locY = TIPS_EDGE_HEIGHT;
        
        if (self.descriptions) {
            result = [NSMutableArray array];
            UIColor *color = self.colorForDescription ? self.colorForDescription : TIPS_DESCROPTIONCOLOR;
            UIFont *font = self.fontForDescription ? self.fontForDescription : [UIFont systemFontOfSize:TIPS_DESCROPTIONFONTSIZE];
            for (NSString *desc in self.descriptions) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                [label setBackgroundColor:[UIColor clearColor]];
                [label setFont:font];
                [label setTextColor:color];
                [label setText:desc];
                label.textAlignment = NSTextAlignmentCenter;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 0;
                
                CGSize fontSize =[desc sizeWithFont:font constrainedToSize:self.recommendLabelSize lineBreakMode:UILineBreakModeWordWrap];
                if (fontSize.width > width) {
                    width = fontSize.width;
                }
                
                label.frame = CGRectMake(TIPS_EDGE_WIDTH, locY, width, fontSize.height + space);
                
                [result addObject:label];
                locY += (fontSize.height + space);
            }
        }
        
        _descLabelsSize.width = (TIPS_EDGE_WIDTH * 2 + width);
        _descLabelsSize.height = (locY - space + TIPS_EDGE_HEIGHT);
    } while (NO);
    return result;
}

- (void)layoutSubviewsForCenter {
    do {
        NSArray *descs = [self prepareDescriptionLabels];
        if (self.triangleHeight != 0) {
            self.triangleHeight = self.triangleHeight > self.recommendLabelSize.width / 2.f ? self.recommendLabelSize.width / 2.f : self.triangleHeight;
        }
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.recommendLabelSize.width, self.recommendLabelSize.height + self.triangleHeight)];
        SAFE_ARC_AUTORELEASE(backgroundView);
        if (self.backgrondImage) {
            backgroundView.image = self.backgrondImage;
        }
    } while (NO);
}

- (void)layoutSubviewsForCenterAncher {
    do {
        ;
    } while (NO);
}

- (void)layoutSubviewsForPopup {
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
