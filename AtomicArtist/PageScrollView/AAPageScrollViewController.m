//
//  AAPageScrollViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-16.
//  Copyright (c) 2012年 ZheJiang University. All rights reserved.
//

#import "AAPageScrollViewController.h"
#import "AAPageView.h"

@interface AAPageScrollViewController () {
    UIInterfaceOrientation _interfaceOrientation;
}

- (AAPageView *)pageViewWithID:(const NSString *)pageID;

- (UIViewController *)pageViewCtrlWithID:(const NSString *)pageID;

- (void)previous;

- (void)next;

- (void)clearUI;

- (void)initPageViews;

@end

@implementation AAPageScrollViewController

@synthesize pageScrollView = _pageScrollView;
@synthesize contextView = _contextView;
@synthesize pageViews = _pageViews;
@synthesize pageViewCtrls = _pageViewCtrls;

- (void)initPageViews {
    if (self.pageViews) {
        [self.pageViews removeAllObjects];
    }
    if (!self.pageViews) {
        self.pageViews = [[[NSMutableDictionary alloc] init] autorelease];
    }
    CGRect rectForPageView = [self.view bounds];
    AAPageView *current = [[[AAPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:current forKey:pageID_current];
    AAPageView *prev = [[[AAPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:prev forKey:pageID_previous];
    AAPageView *next = [[[AAPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:next forKey:pageID_next];
}

- (void)clearUI {
    if (self.pageViews) {
        [self.pageViews removeAllObjects];
    }
    self.contextView = nil;
    self.pageScrollView = nil;
}

- (void)previous {
    // do action for prev, need override by derived class
}

- (void)next {
    // do action for next, need override by derived class
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"AAPageScrollViewController scrollViewDidEndDecelerating:");
    // do action for prev or next
}

- (void)setPageViewCtrlsWithCurrent:(UIViewController *)current previous:(UIViewController *)previous andNext:(UIViewController *)next {
    if (self.pageViewCtrls) {
        [self.pageViewCtrls removeAllObjects];
        [self.pageViewCtrls setObject:current forKey:pageID_current];
        [self.pageViewCtrls setObject:previous forKey:pageID_previous];
        [self.pageViewCtrls setObject:next forKey:pageID_next];
    } else {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: self.pageViewCtrls == nil"];
    }
}

- (void)reloadPageViewWithID:(const NSString *)pageID {
    if (!self.pageViews || !self.pageViewCtrls) {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: self.pageViews == nil or self.pageViewCtrls == nil"];
        return;
    }
    AAPageView *pageView = [self pageViewWithID:pageID];
    UIViewController *pageViewCtrl = [self pageViewCtrlWithID:pageID];
    if (!pageView) {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: pageView for ID: %@", pageID];
        return;
    }
    BOOL needChangeView = YES;
    for (UIView *view in pageView.subviews) {
        if ([view isMemberOfClass:[pageViewCtrl.view class]]) {
            if (view == pageViewCtrl.view) {
                needChangeView = NO;
            } else {
                [view removeFromSuperview];
            }
        } else {
            [view removeFromSuperview];
        }
    }
    if (needChangeView) {
        [pageView addSubview:pageViewCtrl.view];
    }
}

- (void)reloadPageViews {
    if (self.pageViews) {
        [self reloadPageViewWithID:pageID_current];
        [self reloadPageViewWithID:pageID_previous];
        [self reloadPageViewWithID:pageID_next];
    } else {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: self.pageViews == nil"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"AAItemViewController shouldAutorotateToInterfaceOrientation:");
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"AAItemViewController error" format:@"Reason: Current device type unknown"];
    }
    
    if (interfaceOrientation != _interfaceOrientation) {
        _interfaceOrientation = interfaceOrientation;
        // do action for interface rotate
        [self clearUI];
        
        for (UIViewController * viewCtrl in self.pageViewCtrls) {
            [viewCtrl shouldAutorotateToInterfaceOrientation:interfaceOrientation];
        };
        
        CGRect rectForScrollView = [self.view bounds];
        self.pageScrollView = [[[UIScrollView alloc] initWithFrame:rectForScrollView] autorelease];
        CGRect rectForContextView;
        rectForContextView.origin = rectForScrollView.origin;
        rectForContextView.size.width = rectForScrollView.size.width * NUMBEROFPAGEINSCROLLVIEW;
        rectForContextView.size.height = rectForScrollView.size.height;
        self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
        
        [self initPageViews];
        
        [self reloadPageViews];
    }
    
    return result;
}

- (UIViewController *)pageViewCtrlWithID:(const NSString *)pageID {
    if (self.pageViewCtrls && pageID) {
        return [self.pageViewCtrls objectForKey:pageID];
    } else {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: self.pageViewCtrls == nil or pageID == nil"];
        return nil;
    }
}

- (UIViewController *)currentPageViewCtrl {
    return [self pageViewCtrlWithID:pageID_current];
}

- (UIViewController *)previousPageViewCtrl {
    return [self pageViewCtrlWithID:pageID_previous];
}

- (UIViewController *)nextPageViewCtrl {
    return [self pageViewCtrlWithID:pageID_next];
}

- (AAPageView *)pageViewWithID:(NSString *)pageID {
    if (self.pageViews && pageID) {
        return [self.pageViews objectForKey:pageID];
    } else {
        [NSException raise:@"AAPageScrollViewController error" format:@"Reason: self.pageViews == nil or pageID == nil"];
        return nil;
    }
}

- (AAPageView *)currentPageView {
    return [self pageViewWithID:pageID_current];
}

- (AAPageView *)previousPageView {
    return [self pageViewWithID:pageID_previous];
}

- (AAPageView *)nextPageView {
    return [self pageViewWithID:pageID_next];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
