//
//  DCPullReleaseView.m
//  Ares
//
//  Created by Chen XiaoLiang on 13-1-9.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCPullReleaseView.h"

@interface DCPullReleaseView () {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG) UILabel *titleLabel;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UILabel *detailTextLabel;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImageView *arrowView;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *iconContentView;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *actionSwitchView;

- (CGSize)getNewSizeFrom:(CGSize) currentSize toFit:(CGSize) sizeMAX;

@end

@implementation DCPullReleaseView

@synthesize state = _state;
@synthesize type = _type;
@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize detailText = _detailText;
@synthesize arrowImage = _arrowImage;
@synthesize titleLabel = _titleLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize iconContentView = _iconContentView;
@synthesize arrowView = _arrowView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize actionSwitchView = _actionSwitchView;

- (id)initWithFrame:(CGRect)frame {
    [NSException raise:@"DCPullReleaseView error" format:@"use initWithFrame:andType: instead."];
    return nil;
}

- (id)initWithFrame:(CGRect)frame andType:(DCPullReleaseViewType)type {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = type;
        
        CGFloat locX = 0.0;
        CGFloat locY = 0.0;
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        
        // init _actionSwitchView
        locX = 0.0;
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                locY = 0.0;
            }
                break;
                
            case DCPullReleaseViewType_Footer:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_IconContentSize + DCPULLRELEASEVIEW_DefultEdgeInset.bottom;
            }
                break;
                
            default:
            {
                [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
            }
                break;
        }
        width = frame.size.width;
        height = DCPULLRELEASEVIEW_ActionSwitchHeight;
        _actionSwitchView = [[UIView alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.actionSwitchView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.actionSwitchView];
        
        // init _iconContentView
        locX = DCPULLRELEASEVIEW_DefultEdgeInset.left;
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_ActionSwitchHeight;
            }
                break;
                
            case DCPullReleaseViewType_Footer:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top;
            }
                break;
                
            default:
            {
                [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
            }
                break;
        }
        _iconContentView = [[UIView alloc] initWithFrame:CGRectMake(locX, locY, DCPULLRELEASEVIEW_IconContentSize, DCPULLRELEASEVIEW_IconContentSize)];
        self.iconContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconContentView];
        CGSize sizeForIconContentView = self.iconContentView.bounds.size;
        
        // init _activityIndicatorView
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGSize newSizeForActivityIndicatorView = [self getNewSizeFrom:self.activityIndicatorView.bounds.size toFit:sizeForIconContentView];
        self.activityIndicatorView.frame = CGRectMake((DCPULLRELEASEVIEW_IconContentSize - newSizeForActivityIndicatorView.width) / 2, (DCPULLRELEASEVIEW_IconContentSize - newSizeForActivityIndicatorView.height) / 2, newSizeForActivityIndicatorView.width, newSizeForActivityIndicatorView.height);
        [self.iconContentView addSubview:self.activityIndicatorView];
        
        // init _titleLabel
        locX = DCPULLRELEASEVIEW_DefultEdgeInset.left + DCPULLRELEASEVIEW_IconContentSize + DCPULLRELEASEVIEW_InnerSpacing;
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_ActionSwitchHeight;
            }
                break;
                
            case DCPullReleaseViewType_Footer:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top;
            }
                break;
                
            default:
            {
                [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
            }
                break;
        }
        width = frame.size.width - locX - DCPULLRELEASEVIEW_DefultEdgeInset.right;
        height = DCPULLRELEASEVIEW_TitleLabelHeight;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		self.titleLabel.textColor = DCPULLRELEASEVIEW_TextColor;
		self.titleLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        // init _detailTextLabel
        locX = DCPULLRELEASEVIEW_DefultEdgeInset.left + DCPULLRELEASEVIEW_IconContentSize + DCPULLRELEASEVIEW_InnerSpacing;
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_ActionSwitchHeight + DCPULLRELEASEVIEW_InnerSpacing + self.titleLabel.frame.size.height;
            }
                break;
                
            case DCPullReleaseViewType_Footer:
            {
                locY = DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_InnerSpacing + self.titleLabel.frame.size.height;
            }
                break;
                
            default:
            {
                [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
            }
                break;
        }
        width = frame.size.width - locX - DCPULLRELEASEVIEW_DefultEdgeInset.right;
        height = DCPULLRELEASEVIEW_DetailTextLabelHeight;
        _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
		self.detailTextLabel.textColor = DCPULLRELEASEVIEW_TextColor;
		self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.detailTextLabel];
        
        self.state = DCPullReleaseViewState_Common;
    }
    return self;
}

- (void)dealloc {
    do {
        self.delegate = nil;
        self.title = nil;
        self.detailText = nil;
        self.arrowImage = nil;
        
        self.titleLabel = nil;
        self.detailTextLabel = nil;
        self.arrowView = nil;
        self.activityIndicatorView = nil;
        self.iconContentView = nil;
        self.actionSwitchView = nil;
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)setState:(DCPullReleaseViewState)state {
    do {
        _state = state;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            switch (state) {
                case DCPullReleaseViewState_Pulling: {
                    self.title = [self.delegate titleForPullReleaseView:self];
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:DCPULLRELEASEVIEW_FlipAnimationDuration];
                    self.arrowView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                    [CATransaction commit];
                }
                    break;
                case DCPullReleaseViewState_Common: {
                    if (_state == DCPullReleaseViewState_Pulling) {
                        [CATransaction begin];
                        [CATransaction setAnimationDuration:DCPULLRELEASEVIEW_FlipAnimationDuration];
                        self.arrowView.layer.transform = CATransform3DIdentity;
                        [CATransaction commit];
                    }
                    self.title = [self.delegate titleForPullReleaseView:self];
                    [self.activityIndicatorView stopAnimating];
                    [CATransaction begin];
                    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                    self.arrowView.hidden = NO;
                    self.arrowView.layer.transform = CATransform3DIdentity;
                    [CATransaction commit];
                    self.detailText = [self.delegate detailTextForPullReleaseView:self];
                }
                    break;
                case DCPullReleaseViewState_Working: {
                    self.title = [self.delegate titleForPullReleaseView:self];
                    [self.activityIndicatorView startAnimating];
                    [CATransaction begin];
                    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                    self.arrowView.hidden = YES;
                    [CATransaction commit];
                }
                    break;
                default:
                    break;
            }
        });
    } while (NO);
}

- (void)setTitle:(NSString *)title {
    do {
        if (!title) {
            break;
        }
        
        NSString *tmpStr = _title;
        _title = [title copy];
        SAFE_ARC_SAFERELEASE(tmpStr);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.titleLabel.text = title;
        });
    } while (NO);
}

- (void)setDetailText:(NSString *)detailText {
    do {
        if (!detailText) {
            break;
        }
        
        NSString *tmpStr = _detailText;
        _detailText = [detailText copy];
        SAFE_ARC_SAFERELEASE(tmpStr);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.detailTextLabel.text = detailText;
        });
    } while (NO);
}

- (void)setArrowImage:(UIImage *)arrowImage {
    do {
        if (!arrowImage) {
            break;
        }
        
        SAFE_ARC_RETAIN(arrowImage);
        SAFE_ARC_SAFERELEASE(_arrowImage);
        _arrowImage = arrowImage;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            SAFE_ARC_SAFERELEASE(_arrowView);
            CGSize sizeForIconContentView = self.iconContentView.bounds.size;
            _arrowView = [[UIImageView alloc] initWithImage:_arrowImage];
            CGSize newSizeForArrowView = [self getNewSizeFrom:self.arrowView.bounds.size toFit:sizeForIconContentView];
            self.arrowView.frame = CGRectMake((DCPULLRELEASEVIEW_IconContentSize - newSizeForArrowView.width) / 2, (DCPULLRELEASEVIEW_IconContentSize - newSizeForArrowView.height) / 2, newSizeForArrowView.width, newSizeForArrowView.height);
            [self.iconContentView addSubview:self.arrowView];
        });
    } while (NO);
}

- (void)setTitleLabelFont:(UIFont *)font andColor:(UIColor *)color {
    do {
        if (!self.titleLabel) {
            break;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (font) {
                self.titleLabel.font = font;
            }
            if (color) {
                self.titleLabel.textColor = color;
            }
        });
    } while (NO);
}

- (void)setDetailLabelLabelFont:(UIFont *)font andColor:(UIColor *)color {
    do {
        if (!self.detailTextLabel) {
            break;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (font) {
                self.detailTextLabel.font = font;
            }
            if (color) {
                self.detailTextLabel.textColor = color;
            }
        });
    } while (NO);
}

- (void)setActivityIndicatorColor:(UIColor *)color {
    do {
        if (!color) {
            break;
        }
        self.activityIndicatorView.color = color;
    } while (NO);
}

- (void)scrollViewAutoScroll:(UIScrollView*)scrollView{
    do {
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                scrollView.contentOffset = CGPointMake(0, -self.bounds.size.height);
                [self scrollViewDidEndDragging:scrollView];
            }
                break;
            case DCPullReleaseViewType_Footer:
            {
                ;
            }
                break;
            default:
                break;
        }
    } while (NO);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    do {
        CGFloat pullReleaseViewShowHeight = (self.bounds.size.height - DCPULLRELEASEVIEW_ActionSwitchHeight);
        if (self.state == DCPullReleaseViewState_Working) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                CGFloat offset = 0.0;
                switch (self.type) {
                    case DCPullReleaseViewType_Header:
                    {
                        offset = MIN((MAX(scrollView.contentOffset.y * -1, 0)), pullReleaseViewShowHeight);
                        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
                    }
                        break;
                        
                    case DCPullReleaseViewType_Footer:
                    {
                        offset = MIN((MAX(scrollView.contentOffset.y, 0)), pullReleaseViewShowHeight);
                        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
                    }
                        break;
                        
                    default:
                    {
                        [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
                    }
                        break;
                }
                
            });
        } else if (scrollView.isDragging) {
            BOOL working = [self.delegate isWorkingForPullReleaseView:self];
            switch (self.type) {
                case DCPullReleaseViewType_Header:
                {
                    if (self.state == DCPullReleaseViewState_Pulling && scrollView.contentOffset.y > -pullReleaseViewShowHeight && scrollView.contentOffset.y < 0.0f && !working) {
                        self.state = DCPullReleaseViewState_Common;
                    } else if (self.state == DCPullReleaseViewState_Common && scrollView.contentOffset.y < -pullReleaseViewShowHeight && !working) {
                        self.state = DCPullReleaseViewState_Pulling;
                    }
                }
                    break;
                    
                case DCPullReleaseViewType_Footer:
                {
                    CGFloat bottomOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height;
                    if (self.state == DCPullReleaseViewState_Pulling && bottomOffsetY < scrollView.contentSize.height + pullReleaseViewShowHeight && bottomOffsetY > scrollView.contentSize.height && !working) {
                        self.state = DCPullReleaseViewState_Common;
                    } else if (self.state == DCPullReleaseViewState_Common && scrollView.contentOffset.y + scrollView.bounds.size.height > scrollView.contentSize.height + pullReleaseViewShowHeight && !working) {
                        self.state = DCPullReleaseViewState_Pulling;
                    }
                }
                    break;
                    
                default:
                {
                    [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
                }
                    break;
            }
            
            if (scrollView.contentInset.top != 0) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    scrollView.contentInset = UIEdgeInsetsZero;
                });
            }
        }
    } while (NO);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    do {
        BOOL working = [self.delegate isWorkingForPullReleaseView:self];
        CGFloat pullReleaseViewShowHeight = (self.bounds.size.height - DCPULLRELEASEVIEW_ActionSwitchHeight);
        
        switch (self.type) {
            case DCPullReleaseViewType_Header:
            {
                if (scrollView.contentOffset.y < -pullReleaseViewShowHeight && !working) {
                    self.state = DCPullReleaseViewState_Working;
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:DCPULLRELEASEVIEW_EdgeInsetAnimationDuration];
                        scrollView.contentInset = UIEdgeInsetsMake(pullReleaseViewShowHeight, 0.0f, 0.0f, 0.0f);
                        [UIView commitAnimations];
                    });
                    
                    [self.delegate actionRequestFormPullReleaseView:self];
                }
            }
                break;
                
            case DCPullReleaseViewType_Footer:
            {
                CGFloat bottomOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height;
                if (bottomOffsetY > scrollView.contentSize.height + pullReleaseViewShowHeight && !working) {
                    self.state = DCPullReleaseViewState_Working;
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:DCPULLRELEASEVIEW_EdgeInsetAnimationDuration];
                        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, pullReleaseViewShowHeight, 0.0f);
                        [UIView commitAnimations];
                    });
                    
                    [self.delegate actionRequestFormPullReleaseView:self];
                }
            }
                break;
                
            default:
            {
                [NSException raise:@"DCPullReleaseView error" format:@"unknown type"];
            }
                break;
        }
    } while (NO);
}

- (void)dataSourceDidFinishedWorkingWithScrollView:(UIScrollView *)scrollView {
    do {
        self.state = DCPullReleaseViewState_Common;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:DCPULLRELEASEVIEW_EdgeInsetAnimationDuration];
            scrollView.contentInset = UIEdgeInsetsZero;
            [UIView commitAnimations];
        });
    } while (NO);
}

#pragma mark - DCPullReleaseView - Private method
- (CGSize)getNewSizeFrom:(CGSize)currentSize toFit:(CGSize)sizeMAX {
    CGSize result = currentSize;
    do {
        if (currentSize.width > currentSize.height) {
            if (currentSize.width > sizeMAX.width) {
                result.width = sizeMAX.width;
                result.height = currentSize.height * sizeMAX.width / currentSize.width;
            }
        } else {
            if (currentSize.height > sizeMAX.height) {
                result.width = currentSize.width * sizeMAX.height / currentSize.height;
                result.height = sizeMAX.height;
            }
        }
    } while (NO);
    return result;
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
