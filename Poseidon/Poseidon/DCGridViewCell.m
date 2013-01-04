//
//  DCGridViewCell.m
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "DCGridViewCell_Extended.h"
#import "UIView+DCGridViewAdditions.h"

#define DELETEBUTTON_DEFULTOFFSET (-4)
#define DELETEBUTTON_DEFULTSIZE (32)


#pragma mark - interface DCGridViewCell (Private)
@interface DCGridViewCell (Private) {
}

- (void)actionDelete;

@end


#pragma mark - implementation DCGridViewCell
@implementation DCGridViewCell

@synthesize contentView = _contentView;
@synthesize editing = _editing;
@synthesize inShakingMode = _inShakingMode;
@synthesize fullSize = _fullSize;
@synthesize fullSizeView = _fullSizeView;
@synthesize inFullSizeMode = _inFullSizeMode;
@synthesize defaultFullsizeViewResizingMask = _defaultFullsizeViewResizingMask;
@synthesize deleteButton = _deleteButton;
@synthesize deleteBlock = _deleteBlock;
@synthesize deleteButtonIcon = _deleteButtonIcon;
@synthesize deleteButtonOffset;
@synthesize reuseIdentifier;
@synthesize highlighted;

- (id)init {
    return self = [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = !YES;
        self.editing = NO;
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.deleteButtonIcon = nil;
        self.deleteButtonOffset = CGPointMake(DELETEBUTTON_DEFULTOFFSET, DELETEBUTTON_DEFULTOFFSET);
        self.deleteButton.alpha = 0;
        [self addSubview:self.deleteButton];
        [self.deleteButton addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews {
    do {
        if (self.inFullSizeMode) {
            CGPoint origin = CGPointMake((self.bounds.size.width - self.fullSize.width) / 2.0, (self.bounds.size.height - self.fullSize.height) / 2.0);
            self.fullSizeView.frame = CGRectMake(origin.x, origin.y, self.fullSize.width, self.fullSize.height);
        } else {
            self.fullSizeView.frame = self.bounds;
        }
    } while (NO);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    do {
        self.highlighted = YES;
    } while (NO);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    do {
        self.highlighted = NO;
    } while (NO);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    do {
        self.highlighted = NO;
    } while (NO);
}

- (void)setContentView:(UIView *)contentView {
    do {
        [self shake:NO];
        [self.contentView removeFromSuperview];
        
        if (self.contentView) {
            contentView.frame = self.contentView.frame;
        } else {
            contentView.frame = self.bounds;
        }
        
        _contentView = contentView;
        
        self.contentView.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:self.contentView];
        
        [self bringSubviewToFront:self.deleteButton];
    } while (NO);
}

- (void)setFullSizeView:(UIView *)fullSizeView {
    do {
        if ([self isInFullSizeMode]) {
            fullSizeView.frame = _fullSizeView.frame;
            fullSizeView.alpha = _fullSizeView.alpha;
        } else {
            fullSizeView.frame = self.bounds;
            fullSizeView.alpha = 0;
        }
        
        self.defaultFullsizeViewResizingMask = (fullSizeView.autoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        
        fullSizeView.autoresizingMask = _fullSizeView.autoresizingMask;
        
        [_fullSizeView removeFromSuperview];
        _fullSizeView = fullSizeView;
        [self addSubview:_fullSizeView];
        
        [self bringSubviewToFront:self.deleteButton];
    } while (NO);
}

- (void)setFullSize:(CGSize)fullSize {
    do {
        _fullSize = fullSize;
        
        [self setNeedsLayout];
    } while (NO);
}

- (void)setEditing:(BOOL)editing {
    do {
        [self setEditing:editing animated:NO];
    } while (NO);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    do {
        if (editing != _editing) {
            _editing = editing;
            if (animated) {
                [UIView animateWithDuration:0.2f delay:0.f options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut) animations:^{
                    self.deleteButton.alpha = (editing ? 1.f : 0.f);
                } completion:nil];
            } else {
                self.deleteButton.alpha = (editing ? 1.f : 0.f);
            }
            
            self.contentView.userInteractionEnabled = !editing;
            [self shakeStatus:editing];
        }
    } while (NO);
}

- (void)setDeleteButtonOffset:(CGPoint)offset {
    do {
        self.deleteButton.frame = CGRectMake(offset.x, offset.y, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
    } while (NO);
}

- (CGPoint)deleteButtonOffset {
    return self.deleteButton.frame.origin;
}

- (void)setDeleteButtonIcon:(UIImage *)deleteButtonIcon {
    do {
        [self.deleteButton setImage:deleteButtonIcon forState:UIControlStateNormal];
        
        if (deleteButtonIcon) {
            self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, self.deleteButton.frame.origin.y, deleteButtonIcon.size.width, deleteButtonIcon.size.height);
            
            [self.deleteButton setTitle:nil forState:UIControlStateNormal];
            [self.deleteButton setBackgroundColor:[UIColor clearColor]];
        } else {
            self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, self.deleteButton.frame.origin.y, DELETEBUTTON_DEFULTSIZE, DELETEBUTTON_DEFULTSIZE);
            
            [self.deleteButton setTitle:@"X" forState:UIControlStateNormal];
            [self.deleteButton setBackgroundColor:[UIColor lightGrayColor]];
        }
    } while (NO);
}

- (UIImage *)deleteButtonIcon {
    return [self.deleteButton currentImage];
}

- (void)setHighlighted:(BOOL)aHighlighted {
    do {
        highlighted = aHighlighted;
        
        [self.contentView recursiveEnumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop) {
            if ([view respondsToSelector:@selector(setHighlighted:)]) {
                [(UIControl*)view setHighlighted:highlighted];
            }
        }];
    } while (NO);
}

- (void)actionDelete {
    do {
        if (self.deleteBlock) {
            self.deleteBlock(self);
        }
    } while (NO);
}

- (void)prepareForReuse {
    do {
        self.fullSize = CGSizeZero;
        self.fullSizeView = nil;
        self.editing = NO;
        self.deleteBlock = nil;
    } while (NO);
}

- (void)shake:(BOOL)on {
    do {
        if ((on && !self.inShakingMode) || (!on && self.inShakingMode)) {
            [self.contentView shakeStatus:on];
            _inShakingMode = on;
        }
    } while (NO);       
}

- (void)switchToFullSizeMode:(BOOL)fullSizeEnabled {
    do {
        if (fullSizeEnabled)
        {
            self.fullSizeView.autoresizingMask = self.defaultFullsizeViewResizingMask;
            
            CGPoint center = self.fullSizeView.center;
            self.fullSizeView.frame = CGRectMake(self.fullSizeView.frame.origin.x, self.fullSizeView.frame.origin.y, self.fullSize.width, self.fullSize.height);
            self.fullSizeView.center = center;
            
            _inFullSizeMode = YES;
            
            self.fullSizeView.alpha = MAX(self.fullSizeView.alpha, self.contentView.alpha);
            self.contentView.alpha  = 0;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.fullSizeView.alpha = 1;
                                 self.fullSizeView.frame = CGRectMake(self.fullSizeView.frame.origin.x, self.fullSizeView.frame.origin.y, self.fullSize.width, self.fullSize.height);
                                 self.fullSizeView.center = center;
                             }
                             completion:^(BOOL finished){
                                 [self setNeedsLayout];
                             }
             ];
        }
        else
        {
            self.fullSizeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            _inFullSizeMode = NO;
            self.fullSizeView.alpha = 0;
            self.contentView.alpha  = 0.6;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.contentView.alpha  = 1;
                                 self.fullSizeView.frame = self.bounds;
                             }
                             completion:^(BOOL finished){
                                 [self setNeedsLayout];
                             }
             ];
        }
    } while (NO);
}

- (void)stepToFullsizeWithAlpha:(CGFloat)alpha {
    do {
        ;
    } while (NO);
}

@end
