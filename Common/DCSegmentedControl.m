//
//  DCSegmentedControl.m
//  Whip
//
//  Created by Chen XiaoLiang on 13-1-5.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCSegmentedControl.h"

#define BUTTON_TAG_PREFIX (9900)
#define DIVISION_TAG_PREFIX (9800)
#define DIVISIONIMAGEVIEW_TAG_PREFIX (9700)

@interface DCSegmentedControl () {
    NSMutableArray *_buttonArray;
    UIButton *_selectedButton;
    
    NSMutableArray *_divisionArray;
    
    UIImageView *_backgroundImageView;
}

- (void)segmentselected:(id)sender;
- (void)segmentHighlighted:(id)sender;

@end

@implementation DCSegmentedControl

@synthesize delegate = _delegate;
@synthesize divisionWidth = _divisionWidth;
@synthesize segmentWidth = _segmentWidth;
@synthesize segmentCount = _segmentCount;
@synthesize divisioImageForUnselected = _divisioImageForUnselected;
@synthesize divisioImageForLeftSelected = _divisioImageForLeftSelected;
@synthesize divisioImageForRightSelected = _divisioImageForRightSelected;
@synthesize divisioColorForUnselected = _divisioColorForUnselected;
@synthesize divisioColorForLeftSelected = _divisioColorForLeftSelected;
@synthesize divisioColorForRightSelected = _divisioColorForRightSelected;

- (id)initWithFrame:(CGRect)frame segmentCount:(NSUInteger)segmentCount edgeInsets:(UIEdgeInsets)edgeInsets andMinDivisionWidth:(NSUInteger)minDivisionWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundImageView];
        
        _divisioColorForUnselected = _divisioColorForLeftSelected = _divisioColorForRightSelected = [UIColor clearColor];
        SAFE_ARC_RETAIN(_divisioColorForUnselected);
        SAFE_ARC_RETAIN(_divisioColorForLeftSelected);
        SAFE_ARC_RETAIN(_divisioColorForRightSelected);
        
        _divisioImageForUnselected = _divisioImageForLeftSelected = _divisioImageForRightSelected = nil;
        
        _segmentCount = segmentCount;
        if (_segmentCount == 0) {
            [NSException raise:@"DCSegmentedControl error" format:@"segmentCount == 0"];
        }
        
        if (self.segmentCount > 1) {
            while ((((NSUInteger)frame.size.width) - minDivisionWidth * (self.segmentCount - 1)) % self.segmentCount != 0 ) {
                if (minDivisionWidth > ((((NSUInteger)frame.size.width) - self.segmentCount) / (self.segmentCount - 1))) {
                    [NSException raise:@"DCSegmentedControl error" format:@"minDivisionWidth > ((((NSUInteger)frame.size.width) - self.segmentCount) / self.segmentCount))"];
                    break;
                }
                ++minDivisionWidth;
            }
            
            _divisionWidth = minDivisionWidth;
        } else {
            NSAssert(self.segmentCount == 1, @"NSAssert self.segmentCount == 1");
            _divisionWidth = 0;
        }
        
        _segmentWidth = (((NSUInteger)frame.size.width) - self.divisionWidth * (self.segmentCount - 1)) / self.segmentCount;
        
        _buttonArray = [NSMutableArray arrayWithCapacity:self.segmentCount];
        SAFE_ARC_RETAIN(_buttonArray);
        _selectedButton = nil;
        _divisionArray = [NSMutableArray arrayWithCapacity:(self.segmentCount - 1)];
        SAFE_ARC_RETAIN(_divisionArray);
        
        NSUInteger locX = edgeInsets.left;
        NSUInteger locY = edgeInsets.top;
        NSUInteger locMAX = frame.size.width - edgeInsets.left - edgeInsets.right;
        NSUInteger itemHeight = frame.size.height - edgeInsets.top - edgeInsets.bottom;
        
        for (NSUInteger idx = 0; idx < self.segmentCount; ++idx) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(locX, locY, self.segmentWidth, itemHeight);
            locX += self.segmentWidth;
            btn.tag = idx + BUTTON_TAG_PREFIX;
            btn.backgroundColor = [UIColor clearColor];
            btn.adjustsImageWhenHighlighted = NO;
            [btn addTarget:self action:@selector(segmentselected:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(segmentHighlighted:) forControlEvents:UIControlEventTouchDown];
            
            [_buttonArray addObject:btn];
            [self addSubview:btn];
            
            if (self.divisionWidth != 0 && idx < self.segmentCount - 1 && locX < locMAX) {
                UIImageView *divisionView = [[UIImageView alloc] initWithFrame:CGRectMake(locX, locY, self.divisionWidth, itemHeight)];
                SAFE_ARC_AUTORELEASE(divisionView);
                locX += self.divisionWidth;
                divisionView.tag = idx + DIVISION_TAG_PREFIX;
                divisionView.backgroundColor = [UIColor clearColor];
                
                [_divisionArray addObject:divisionView];
                [self addSubview:divisionView];
            }
        }
        
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)aImage {
    do {
        if (!_backgroundImageView || !aImage) {
            break;
        }
        _backgroundImageView.image = aImage;
    } while (NO);
}

- (void)setBackgroundViewColor:(UIColor *)aColor {
    do {
        if (!_backgroundImageView || !aColor) {
            break;
        }
        _backgroundImageView.backgroundColor = aColor;
    } while (NO);
}

- (void)setDefultselectedSegment:(NSUInteger)index {
    do {
        if (index >= [_buttonArray count] || _selectedButton) {
            break;
        }
        _selectedButton = (UIButton *)[_buttonArray objectAtIndex:index];
        _selectedButton.selected = YES;
        
        if (self.delegate) {
            [self.delegate valueChanged:(_selectedButton.tag - BUTTON_TAG_PREFIX)];
        }
    } while (NO);
}

- (void)dealloc {
    do {
        self.divisioColorForUnselected = nil;
        self.divisioColorForLeftSelected = nil;
        self.divisioColorForRightSelected = nil;
        self.divisioImageForUnselected = nil;
        self.divisioImageForLeftSelected = nil;
        self.divisioImageForRightSelected = nil;
        
        SAFE_ARC_SAFERELEASE(_backgroundImageView);
                
        if (_divisionArray) {
            [_divisionArray removeAllObjects];
            SAFE_ARC_SAFERELEASE(_divisionArray);
        }
        
        if (_buttonArray) {
            for (UIButton *btn in _buttonArray) {
                [btn removeTarget:self action:@selector(segmentselected:) forControlEvents:UIControlEventTouchUpInside];
                [btn removeTarget:self action:@selector(segmentHighlighted:) forControlEvents:UIControlEventTouchDown];
            }
            [_buttonArray removeAllObjects];
            SAFE_ARC_SAFERELEASE(_buttonArray);
        }
        
        self.delegate = nil;
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)layoutSubviews {
    do {
        NSUInteger idx = 0;
        for (UIImageView *view in _divisionArray) {
            UIButton *leftBtn = [_buttonArray objectAtIndex:idx];
            UIButton *rightBtn = [_buttonArray objectAtIndex:(idx + 1)];
            
            UIImage *img = nil;
            UIColor *color = [UIColor clearColor];
            
            if (leftBtn.isSelected) {
                img = self.divisioImageForLeftSelected;
                color = self.divisioColorForLeftSelected;
            } else if (rightBtn.isSelected) {
                img = self.divisioImageForRightSelected;
                color = self.divisioColorForRightSelected;
            } else {
                img = self.divisioImageForUnselected;
                color = self.divisioColorForUnselected;
            }
            
            view.backgroundColor = color;
            view.image = img;
            
            ++idx;
        }
    } while (NO);
}

- (void)segmentselected:(id)sender {
    do {
        if (!sender) {
            break;
        }
        if (![sender isKindOfClass:[UIButton class]]) {
            break;
        }
        UIButton *btn = (UIButton *)sender;
        btn.highlighted = NO;
        if (_selectedButton != btn) {
            _selectedButton.selected = NO;
            _selectedButton = btn;
            if (!_selectedButton.isSelected) {
                _selectedButton.selected = YES;
            }
            [self setNeedsLayout];
            if (self.delegate) {
                [self.delegate valueChanged:(_selectedButton.tag - BUTTON_TAG_PREFIX)];
            }
        }
    } while (NO);
}

- (void)segmentHighlighted:(id)sender {
    do {
        if (!sender) {
            break;
        }
        if (![sender isKindOfClass:[UIButton class]]) {
            break;
        }
        UIButton *btn = (UIButton *)sender;
        btn.highlighted = NO;
    } while (NO);
}

- (UIButton *)SegmentAtIndex:(NSUInteger)index {
    UIButton *result = nil;
    do {
        if (index >= [_buttonArray count]) {
            break;
        }
        
        result = [_buttonArray objectAtIndex:index];
        SAFE_ARC_RETAIN(result);
        SAFE_ARC_AUTORELEASE(result);
    } while (NO);
    return result;
}

- (void)customizeSegmentAtIndex:(NSUInteger)index withImage:(UIImage *)image forState:(UIControlState)state {
    do {
        if (index >= [_buttonArray count] || !image) {
            break;
        }
        UIButton *btn = [_buttonArray objectAtIndex:index];
        [btn setBackgroundImage:image forState:state];
    } while (NO);
}

- (void)customizeSegmentAtIndex:(NSUInteger)index withTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color forState:(UIControlState)state {
    do {
        if (index >= [_buttonArray count] || !title) {
            break;
        }
        UIButton *btn = [_buttonArray objectAtIndex:index];
        if (font) {
            btn.titleLabel.font = font;
        }
        if (color) {
            [btn setTitleColor:color forState:state];
        }
        [btn setTitle:title forState:state];
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
