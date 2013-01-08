//
//  DCPullOutView.m
//  Ares
//
//  Created by Chen XiaoLiang on 13-1-8.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCPullOutView.h"

@interface DCPullOutView () {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *iconContentView;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *actionSwitchView;

- (CGSize)getNewSizeFrom:(CGSize) currentSize toFit:(CGSize) sizeMAX;

@end

@implementation DCPullOutView

@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize detailText = _detailText;
@synthesize titleLabel = _titleLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize iconContentView = _iconContentView;
@synthesize arrowView = _arrowView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize actionSwitchView = _actionSwitchView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat locX = 0.0;
        CGFloat locY = 0.0;
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        
        // init _actionSwitchView
        locX = 0.0;
        locY = 0.0;
        width = frame.size.width;
        height = DCPULLOUTVIEW_ActionSwitchHeight;
        _actionSwitchView = [[UIView alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.actionSwitchView.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.actionSwitchView];
        
        // init _iconContentView
        locX = DCPULLOUTVIEW_DefultEdgeInset.left;
        locY = DCPULLOUTVIEW_DefultEdgeInset.top + DCPULLOUTVIEW_ActionSwitchHeight;
        _iconContentView = [[UIView alloc] initWithFrame:CGRectMake(locX, locY, DCPULLOUTVIEW_IconContentSize, DCPULLOUTVIEW_IconContentSize)];
        self.iconContentView.backgroundColor = [UIColor redColor];
        [self addSubview:self.iconContentView];
        CGSize sizeForIconContentView = self.iconContentView.frame.size;
        
        // init _arrowView
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow.png"]];
        CGSize newSizeForArrowView = [self getNewSizeFrom:self.arrowView.frame.size toFit:sizeForIconContentView];
        self.arrowView.frame = CGRectMake((DCPULLOUTVIEW_IconContentSize - newSizeForArrowView.width) / 2, (DCPULLOUTVIEW_IconContentSize - newSizeForArrowView.height) / 2, newSizeForArrowView.width, newSizeForArrowView.height);
        [self.iconContentView addSubview:self.arrowView];
        
        // init _activityIndicatorView
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGSize newSizeForActivityIndicatorView = [self getNewSizeFrom:self.activityIndicatorView.frame.size toFit:sizeForIconContentView];
        self.activityIndicatorView.frame = CGRectMake((DCPULLOUTVIEW_IconContentSize - newSizeForActivityIndicatorView.width) / 2, (DCPULLOUTVIEW_IconContentSize - newSizeForActivityIndicatorView.height) / 2, newSizeForActivityIndicatorView.width, newSizeForActivityIndicatorView.height);
        [self.iconContentView addSubview:self.activityIndicatorView];
        
        // init _titleLabel
        locX = DCPULLOUTVIEW_DefultEdgeInset.left + DCPULLOUTVIEW_IconContentSize + DCPULLOUTVIEW_InnerSpacing;
        locY = DCPULLOUTVIEW_DefultEdgeInset.top + DCPULLOUTVIEW_ActionSwitchHeight;
        width = frame.size.width - locX - DCPULLOUTVIEW_DefultEdgeInset.right;
        height = DCPULLOUTVIEW_TitleLabelHeight;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		self.titleLabel.textColor = DCPULLOUTVIEW_TextColor;
		self.titleLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.titleLabel.backgroundColor = [UIColor greenColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        // init _detailTextLabel
        locX = DCPULLOUTVIEW_DefultEdgeInset.left + DCPULLOUTVIEW_IconContentSize + DCPULLOUTVIEW_InnerSpacing;
        locY = DCPULLOUTVIEW_DefultEdgeInset.top + DCPULLOUTVIEW_ActionSwitchHeight + DCPULLOUTVIEW_InnerSpacing + self.titleLabel.frame.size.height;
        width = frame.size.width - locX - DCPULLOUTVIEW_DefultEdgeInset.right;
        height = DCPULLOUTVIEW_DetailTextLabelHeight;
        _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(locX, locY, width, height)];
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
		self.detailTextLabel.textColor = DCPULLOUTVIEW_TextColor;
		self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.detailTextLabel.backgroundColor = [UIColor blueColor];
		self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.detailTextLabel];
        
        self.state = DCPullOutViewState_Common;
    }
    return self;
}

- (void)dealloc {
    do {
        self.delegate = nil;
        self.title = nil;
        self.detailText = nil;
        
        SAFE_ARC_SAFERELEASE(_titleLabel);
        SAFE_ARC_SAFERELEASE(_detailTextLabel);
        SAFE_ARC_SAFERELEASE(_arrowView);
        SAFE_ARC_SAFERELEASE(_activityIndicatorView);
        self.iconContentView = nil;
        self.actionSwitchView = nil;
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)setState:(DCPullOutViewState)state {
    do {
        _state = state;
        switch (state) {
            case DCPullOutViewState_Pulling: {
                self.title = [self.delegate dcPullOutViewDataSourceTitle];
                [CATransaction begin];
                [CATransaction setAnimationDuration:DCPULLOUTVIEW_FlipAnimationDuration];
                self.arrowView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
            }
                break;
            case DCPullOutViewState_Common: {
                if (_state == DCPullOutViewState_Pulling) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:DCPULLOUTVIEW_FlipAnimationDuration];
                    self.arrowView.layer.transform = CATransform3DIdentity;
                    [CATransaction commit];
                }
                self.title = [self.delegate dcPullOutViewDataSourceTitle];
                [self.activityIndicatorView stopAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                self.arrowView.hidden = NO;
                self.arrowView.layer.transform = CATransform3DIdentity;
                [CATransaction commit];
                self.detailText = [self.delegate dcPullOutViewDataSourceDetailText];
            }
                break;
            case DCPullOutViewState_Working: {
                self.title = [self.delegate dcPullOutViewDataSourceTitle];
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
        
        self.titleLabel.text = title;
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
        
        self.detailTextLabel.text = detailText;
    } while (NO);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    do {
        if (self.state == DCPullOutViewState_Working) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, (self.frame.size.height - DCPULLOUTVIEW_ActionSwitchHeight));
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        } else if (scrollView.isDragging) {
            BOOL working = [self.delegate dcPullOutViewDataSourceIsWorking:self];
            
            if (self.state == DCPullOutViewState_Pulling && scrollView.contentOffset.y > -(self.frame.size.height - DCPULLOUTVIEW_ActionSwitchHeight) && scrollView.contentOffset.y < 0.0f && !working) {
                self.state = DCPullOutViewState_Common;
            } else if (self.state == DCPullOutViewState_Common && scrollView.contentOffset.y < -(self.frame.size.height - DCPULLOUTVIEW_ActionSwitchHeight) && !working) {
                self.state = DCPullOutViewState_Pulling;
            }
            
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
            
        }
    } while (NO);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    do {
        BOOL working = [self.delegate dcPullOutViewDataSourceIsWorking:self];
        
        if (scrollView.contentOffset.y < -(self.frame.size.height - DCPULLOUTVIEW_ActionSwitchHeight) && !working) {
            [self.delegate dcPullOutViewDidAction:self];
            
            self.state = DCPullOutViewState_Working;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            scrollView.contentInset = UIEdgeInsetsMake((self.frame.size.height - DCPULLOUTVIEW_ActionSwitchHeight), 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
            
        }
    } while (NO);
}

- (void)scrollViewDataSourceDidFinishedWorking:(UIScrollView *)scrollView {
    do {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        self.state = DCPullOutViewState_Common;
    } while (NO);
}

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
