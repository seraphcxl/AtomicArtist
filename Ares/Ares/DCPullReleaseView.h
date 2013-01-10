//
//  DCPullReleaseView.h
//  Ares
//
//  Created by Chen XiaoLiang on 13-1-9.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SafeARC.h"
#import "DCCommonConstants.h"

#define DCPULLRELEASEVIEW_ActionSwitchHeight (16.0)
#define DCPULLRELEASEVIEW_DefultEdgeInset UIEdgeInsetsMake(8.0, 16.0, 8.0, 16.0)
#define DCPULLRELEASEVIEW_IconContentSize (64.0)
#define DCPULLRELEASEVIEW_Height (DCPULLRELEASEVIEW_IconContentSize + DCPULLRELEASEVIEW_DefultEdgeInset.top + DCPULLRELEASEVIEW_DefultEdgeInset.bottom + DCPULLRELEASEVIEW_ActionSwitchHeight)
#define DCPULLRELEASEVIEW_InnerSpacing (4.0)
#define DCPULLRELEASEVIEW_TitleLabelHeight (32.0)
#define DCPULLRELEASEVIEW_DetailTextLabelHeight (24.0)

#define DCPULLRELEASEVIEW_TextColor [UIColor darkTextColor]
#define DCPULLRELEASEVIEW_FlipAnimationDuration 0.25f
#define DCPULLRELEASEVIEW_EdgeInsetAnimationDuration 0.2f

typedef enum{
    DCPullReleaseViewState_Common = 0,
	DCPullReleaseViewState_Pulling,
	DCPullReleaseViewState_Working,
} DCPullReleaseViewState;

typedef enum{
    DCPullReleaseViewType_Header = 0,
	DCPullReleaseViewType_Footer,
} DCPullReleaseViewType;

@class DCPullReleaseView;

@protocol DCPullReleaseViewDelegate <NSObject>

@required
- (NSString *)titleForPullReleaseView:(DCPullReleaseView *)view;
- (NSString *)detailTextForPullReleaseView:(DCPullReleaseView *)view;

- (void)actionRequestFormPullReleaseView:(DCPullReleaseView *)view;
- (BOOL)isWorkingForPullReleaseView:(DCPullReleaseView *)view;

@optional
- (void)relocatePullReleaseView:(DCPullReleaseView *)view;
- (NSDate *)getLastUpdatedDateForPullReleaseView:(DCPullReleaseView *)view;

@end

@interface DCPullReleaseView : UIView {
}

@property (nonatomic, assign) DCPullReleaseViewState state;
@property (nonatomic, assign) DCPullReleaseViewType type;

@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCPullReleaseViewDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImage *arrowImage;

- (id)initWithFrame:(CGRect)frame andType:(DCPullReleaseViewType)type;

- (void)setTitleLabelFont:(UIFont *)font andColor:(UIColor *)color;
- (void)setDetailLabelLabelFont:(UIFont *)font andColor:(UIColor *)color;
- (void)setActivityIndicatorColor:(UIColor *)color;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)dataSourceDidFinishedWorkingWithScrollView:(UIScrollView *)scrollView;

@end
