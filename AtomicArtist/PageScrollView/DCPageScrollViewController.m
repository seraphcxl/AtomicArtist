//
//  DCPageScrollViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCPageScrollViewController.h"
#import "DCPageView.h"

NSString * const pageID_current = @"current";
NSString * const pageID_previous = @"previous";
NSString * const pageID_next = @"next";

@interface DCPageScrollViewController () {
//    UIInterfaceOrientation _interfaceOrientation;
}

- (DCPageView *)pageViewWithID:(const NSString *)pageID;

- (UIViewController *)viewCtrlWithID:(const NSString *)pageID;

- (void)previous;

- (void)next;

- (void)clearUI;

- (void)initPageViews;


@end

@implementation DCPageScrollViewController

@synthesize delegate = _delegate;
@synthesize pageScrollView = _pageScrollView;
@synthesize contextView = _contextView;
@synthesize pageViews = _pageViews;
@synthesize viewCtrls = _viewCtrls;
@synthesize scrollEnabled = _scrollEnabled;

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    if (self.pageScrollView) {
//        self.pageScrollView.scrollEnabled = scrollEnabled;
    }
}

- (void)initPageViews {
    if (!self.contextView) {
        [NSException raise:@"DCPageScrollViewController error" format:@"self.contextView == nil"];
    }
    if (self.contextView) {
        for (DCPageView *pageView in self.contextView.subviews) {
            if ([pageView isMemberOfClass:[DCPageView class]]) {
                [pageView removeFromSuperview];
            }
        }
    }
    if (self.pageViews) {
        [self.pageViews removeAllObjects];
    }
    if (!self.pageViews) {
        self.pageViews = [[[NSMutableDictionary alloc] init] autorelease];
    }
    CGRect rectForPageView = [self.view bounds];
    DCPageView *prev = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:prev forKey:pageID_previous];
    
    rectForPageView.origin.x += rectForPageView.size.width;
    DCPageView *current = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:current forKey:pageID_current];
    
    rectForPageView.origin.x += rectForPageView.size.width;
    DCPageView *next = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
    [self.pageViews setObject:next forKey:pageID_next];
    
    [self.contextView addSubview:prev];
    [self.contextView addSubview:current];
    [self.contextView addSubview:next];
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
    
    if (self.delegate) {
        [self.delegate pageScrollViewCtrl:self doPreviousActionWithCurrentViewCtrl:[self currentViewCtrl] previousViewCtrl:[self previousViewCtrl]];
    }
}

- (void)next {
    // do action for next, need override by derived class
    
    if (self.delegate) {
        [self.delegate pageScrollViewCtrl:self doNextActionWithCurrentViewCtrl:[self currentViewCtrl] nextViewCtrl:[self nextViewCtrl]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewWillBeginDragging:");
//    [[self previousViewCtrl] viewWillAppear:YES];
//    [[self nextViewCtrl] viewWillAppear:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewWillBeginDecelerating:");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewDidEndDecelerating:");
    // do action for prev or next
    CGPoint offset = [scrollView contentOffset];
    CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
    CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
    if (offset.x == prevPageViewOffset.x && offset.y == prevPageViewOffset.y) {
        [self previous];
    } else if (offset.x == nextPageViewOffset.x && offset.y == nextPageViewOffset.y) {
        [self next];
    } else {
        NSLog(@"Warning");
    }
}

- (void)setViewCtrlsWithCurrent:(UIViewController *)current previous:(UIViewController *)previous andNext:(UIViewController *)next {
    if (self.viewCtrls) {
        [self.viewCtrls removeAllObjects];
        
        [self.viewCtrls setObject:previous forKey:pageID_previous];
        [self.viewCtrls setObject:current forKey:pageID_current];
        [self.viewCtrls setObject:next forKey:pageID_next];
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: self.viewCtrls == nil"];
    }
}

- (void)reloadPageViewWithID:(const NSString *)pageID {
    if (!self.pageViews || !self.viewCtrls) {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: self.pageViews == nil or self.viewCtrls == nil"];
        return;
    }
    DCPageView *pageView = [self pageViewWithID:pageID];
    UIViewController *pageViewCtrl = [self viewCtrlWithID:pageID];
    if (!pageView) {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: pageView for ID: %@", pageID];
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
        CGRect rect = pageView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        [pageViewCtrl.view setFrame:rect];
        [pageView addSubview:pageViewCtrl.view];
    }
}

- (void)reloadPageViews {
    if (self.pageViews) {
        [self reloadPageViewWithID:pageID_previous];
        [self reloadPageViewWithID:pageID_current];
        [self reloadPageViewWithID:pageID_next];
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: self.pageViews == nil"];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!self.pageViews) {
            self.pageViews = [[[NSMutableDictionary alloc] init] autorelease];
        }
        
        if (!self.viewCtrls) {
            self.viewCtrls = [[[NSMutableDictionary alloc] init] autorelease];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect rectForScrollView = [self.view bounds];
    self.pageScrollView = [[[UIScrollView alloc] initWithFrame:rectForScrollView] autorelease];
    CGRect rectForContextView;
    rectForContextView.origin = rectForScrollView.origin;
    rectForContextView.size.width = rectForScrollView.size.width * NUMBEROFPAGEINSCROLLVIEW;
    rectForContextView.size.height = rectForScrollView.size.height;
    self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
    [self.contextView setBackgroundColor:[UIColor clearColor]];
    [self initPageViews];
    
    [self reloadPageViews];
    
    [[self currentViewCtrl] viewWillAppear:animated];
//    NSArray *allViewCtrls = [self.viewCtrls allValues];
//    for (UIViewController *viewCtrl in allViewCtrls) {
//        [viewCtrl viewWillAppear:animated];
//    };
    
    [self.pageScrollView addSubview:self.contextView];
    [self.pageScrollView setContentSize:rectForContextView.size];
    DCPageView *currentPageView = [self currentPageView];
    CGPoint offset = currentPageView.frame.origin;
    [self.pageScrollView setContentOffset:offset animated:NO];
//    self.pageScrollView.scrollEnabled = self.scrollEnabled;
    self.pageScrollView.pagingEnabled = YES;
    [self.pageScrollView setDelegate:self];
    [self.view addSubview:self.pageScrollView];
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
    NSLog(@"DCItemViewController shouldAutorotateToInterfaceOrientation:");
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: Current device type unknown"];
    }
    BOOL needRotate = NO;
    if (self.pageScrollView) {
        CGRect rectForScrollView = [self.pageScrollView bounds];
        CGRect rectForView = [self.view bounds];
        if (rectForView.size.width != rectForScrollView.size.width) {
            needRotate = YES;
        }
    } else {
        needRotate = YES;
    }
    if (needRotate) {
//        _interfaceOrientation = interfaceOrientation;
        // do action for interface rotate
        [self clearUI];
        
        CGRect rectForScrollView = [self.view bounds];
        self.pageScrollView = [[[UIScrollView alloc] initWithFrame:rectForScrollView] autorelease];
        CGRect rectForContextView;
        rectForContextView.origin = rectForScrollView.origin;
        rectForContextView.size.width = rectForScrollView.size.width * NUMBEROFPAGEINSCROLLVIEW;
        rectForContextView.size.height = rectForScrollView.size.height;
        self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
        [self.contextView setBackgroundColor:[UIColor clearColor]];
        [self initPageViews];
        
        [self reloadPageViews];
        
        NSArray *allViewCtrls = [self.viewCtrls allValues];
        for (UIViewController *viewCtrl in allViewCtrls) {
            [viewCtrl shouldAutorotateToInterfaceOrientation:interfaceOrientation];
        };
        
        [self.pageScrollView addSubview:self.contextView];
        [self.pageScrollView setContentSize:rectForContextView.size];
        DCPageView *currentPageView = [self currentPageView];
        CGPoint offset = currentPageView.frame.origin;
        [self.pageScrollView setContentOffset:offset animated:NO];
//        self.pageScrollView.scrollEnabled = self.scrollEnabled;
        self.pageScrollView.pagingEnabled = YES;
        [self.pageScrollView setDelegate:self];
        [self.view addSubview:self.pageScrollView];
    }
    
    return result;
}

- (UIViewController *)viewCtrlWithID:(const NSString *)pageID {
    if (self.viewCtrls && pageID) {
        return [self.viewCtrls objectForKey:pageID];
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: self.viewCtrls == nil or pageID == nil"];
        return nil;
    }
}

- (UIViewController *)currentViewCtrl {
    return [self viewCtrlWithID:pageID_current];
}

- (UIViewController *)previousViewCtrl {
    return [self viewCtrlWithID:pageID_previous];
}

- (UIViewController *)nextViewCtrl {
    return [self viewCtrlWithID:pageID_next];
}

- (DCPageView *)pageViewWithID:(NSString *)pageID {
    if (self.pageViews && pageID) {
        return [self.pageViews objectForKey:pageID];
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: self.pageViews == nil or pageID == nil"];
        return nil;
    }
}

- (DCPageView *)currentPageView {
    return [self pageViewWithID:pageID_current];
}

- (DCPageView *)previousPageView {
    return [self pageViewWithID:pageID_previous];
}

- (DCPageView *)nextPageView {
    return [self pageViewWithID:pageID_next];
}
@end
