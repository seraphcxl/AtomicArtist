//
//  DCPageScrollViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCDetailViewController.h"

@class DCPageView;

extern NSString * const pageID_current;
extern NSString * const pageID_previous;
extern NSString * const pageID_next;

@class DCPageScrollViewController;

@protocol DCPageScrollViewControllerDelegate <NSObject>

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doNextActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl nextViewCtrl:(UIViewController *)nextViewCtrl;
- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doPreviousActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl previousViewCtrl:(UIViewController *)previousViewCtrl;

@end

@interface DCPageScrollViewController : UIViewController <UIScrollViewDelegate, DCDetailViewControllerDelegate>

@property (assign, nonatomic) id <DCPageScrollViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (retain, nonatomic) UIView *contextView;
@property (retain, nonatomic) NSMutableDictionary *pageViews;
@property (retain, nonatomic) NSMutableDictionary *viewCtrls;
@property (assign, nonatomic) BOOL scrollEnabled;
@property (assign, nonatomic) BOOL hideNavigationBarEnabled;

- (DCPageView *)currentPageView;
- (DCPageView *)previousPageView;
- (DCPageView *)nextPageView;

- (UIViewController *)currentViewCtrl;
- (UIViewController *)previousViewCtrl;
- (UIViewController *)nextViewCtrl;

- (void)setViewCtrlsWithCurrent:(UIViewController *)current previous:(UIViewController *)previous andNext:(UIViewController *)next;

- (void)reloadPageViews;
- (void)reloadPageViewWithID:(const NSString *)pageID;

- (void)scrollToCurrentPageView;

@end
