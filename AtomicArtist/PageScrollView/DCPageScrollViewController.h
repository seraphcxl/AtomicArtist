//
//  DCPageScrollViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCPageView;

#define NUMBEROFPAGEINSCROLLVIEW ((int)3)

const NSString *pageID_current = @"current";
const NSString *pageID_previous = @"previous";
const NSString *pageID_next = @"next";

@interface DCPageScrollViewController : UIViewController <UIScrollViewDelegate>

@property (retain, nonatomic) UIScrollView *pageScrollView;
@property (retain, nonatomic) UIView *contextView;
@property (retain, nonatomic) NSMutableDictionary *pageViews;
@property (retain, nonatomic) NSMutableDictionary *pageViewCtrls;
@property (assign, nonatomic) BOOL scrollEnabled;

- (DCPageView *)currentPageView;
- (DCPageView *)previousPageView;
- (DCPageView *)nextPageView;

- (UIViewController *)currentPageViewCtrl;
- (UIViewController *)previousPageViewCtrl;
- (UIViewController *)nextPageViewCtrl;

- (void)setPageViewCtrlsWithCurrent:(UIViewController *)current previous:(UIViewController *)previous andNext:(UIViewController *)next;

- (void)reloadPageViews;
- (void)reloadPageViewWithID:(const NSString *)pageID;

@end
