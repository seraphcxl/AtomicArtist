//
//  DCPullOutView.h
//  Ares
//
//  Created by Chen XiaoLiang on 13-1-8.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SafeARC.h"
#import "DCCommonConstants.h"

#define DCPULLOUTVIEW_ActionSwitchHeight (8.0)
#define DCPULLOUTVIEW_DefultEdgeInset UIEdgeInsetsMake(8.0, 16.0, 8.0, 16.0)
#define DCPULLOUTVIEW_IconContentSize (64.0)
#define DCPULLOUTVIEW_Height (DCPULLOUTVIEW_IconContentSize + DCPULLOUTVIEW_DefultEdgeInset.top + DCPULLOUTVIEW_DefultEdgeInset.bottom + DCPULLOUTVIEW_ActionSwitchHeight)
#define DCPULLOUTVIEW_InnerSpacing (4.0)
#define DCPULLOUTVIEW_TitleLabelHeight (32.0)
#define DCPULLOUTVIEW_DetailTextLabelHeight (24.0)

#define DCPULLOUTVIEW_TextColor [UIColor darkTextColor]
#define DCPULLOUTVIEW_FlipAnimationDuration 0.25f


typedef enum{
    DCPullOutViewState_Common = 0,
	DCPullOutViewState_Pulling,
	DCPullOutViewState_Working,
} DCPullOutViewState;

@class DCPullOutView;

@protocol DCPullOutViewDelegate <NSObject>

@required
- (NSString *)dcPullOutViewDataSourceTitle;
- (NSString *)dcPullOutViewDataSourceDetailText;

- (void)dcPullOutViewDidAction:(DCPullOutView *)view;
- (BOOL)dcPullOutViewDataSourceIsWorking:(DCPullOutView *)view;

@optional
- (NSDate *)dcPullOutViewDataSourceLastUpdated:(DCPullOutView *)view;

@end

@interface DCPullOutView : UIView {
}

@property (nonatomic, assign) DCPullOutViewState state;

@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCPullOutViewDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *detailTextLabel;
@property (nonatomic, readonly) UIImageView *arrowView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)scrollViewDataSourceDidFinishedWorking:(UIScrollView *)scrollView;

@end
