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

typedef enum {
    PAGEINDEX_PREVIOUS = 0x00000000,
    PAGEINDEX_CURRENT,
    PAGEINDEX_NEXT,
    
    PAGEINDEX_COUNT,
} PAGEINDEX;

@interface DCPageScrollViewController () {
    UIInterfaceOrientation _interfaceOrientation;
    BOOL enableViews[PAGEINDEX_COUNT];
    BOOL needCallViewWillAppear[PAGEINDEX_COUNT];
    BOOL needCallViewRotate[PAGEINDEX_COUNT];
    
    CGPoint scrollViewOffset;
}

- (DCPageView *)pageViewWithID:(const NSString *)pageID;

- (UIViewController *)viewCtrlWithID:(const NSString *)pageID;

- (void)previous;

- (void)next;

- (void)clearUI;

- (void)initPageViews;

- (void)setView:(PAGEINDEX)index appearFlag:(BOOL)flag;

- (void)setView:(PAGEINDEX)index rotateFlag:(BOOL)flag;

@end

@implementation DCPageScrollViewController

@synthesize delegate = _delegate;
@synthesize pageScrollView = _pageScrollView;
@synthesize contextView = _contextView;
@synthesize pageViews = _pageViews;
@synthesize viewCtrls = _viewCtrls;
@synthesize scrollEnabled = _scrollEnabled;

- (void)scrollToCurrentPageView {
    DCPageView *currentPageView = [self currentPageView];
    if (currentPageView) {
        scrollViewOffset = currentPageView.frame.origin;
        [self.pageScrollView setContentOffset:scrollViewOffset animated:NO];
        if (needCallViewWillAppear[PAGEINDEX_CURRENT]) {
            [[self currentViewCtrl] viewWillAppear:YES];
            [self setView:PAGEINDEX_CURRENT appearFlag:NO];
        }
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: currentPageView == nil"];
    }
    
}

- (void)detailImageViewTypeChanged:(DETAILIMAGEVIEWTYPE)type {
    if (type == DETAILIMAGEVIEWTYPE_FITIN) {
        [self setScrollEnabled:YES];
    } else if (type == DETAILIMAGEVIEWTYPE_ORIGIN) {
        [self setScrollEnabled:NO];
    } else {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: unknown detail image view type:%d", type];
    }
}

- (void)setView:(PAGEINDEX)index appearFlag:(BOOL)flag {
    if (index >= PAGEINDEX_COUNT) {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: index <= PAGEINDEX_COUNT"];
        return;
    }
    needCallViewWillAppear[index] = flag;
    if (flag) {
        needCallViewRotate[index] = NO;
    }
}

- (void)setView:(PAGEINDEX)index rotateFlag:(BOOL)flag {
    if (index >= PAGEINDEX_COUNT) {
        [NSException raise:@"DCPageScrollViewController error" format:@"Reason: index <= PAGEINDEX_COUNT"];
        return;
    }
    if (flag) {
        if (!needCallViewWillAppear[index]) {
            needCallViewRotate[index] = flag;
        }
    } else {
        needCallViewRotate[index] = flag;
    }
    
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    if (self.pageScrollView) {
        self.pageScrollView.scrollEnabled = scrollEnabled;
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
    if (enableViews[PAGEINDEX_PREVIOUS]) {
        DCPageView *prev = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
        [self.pageViews setObject:prev forKey:pageID_previous];
        [self.contextView addSubview:prev];
        rectForPageView.origin.x += rectForPageView.size.width;
    }
    
    if (enableViews[PAGEINDEX_CURRENT]) {
        DCPageView *current = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
        [self.pageViews setObject:current forKey:pageID_current];
        [self.contextView addSubview:current];
        rectForPageView.origin.x += rectForPageView.size.width;
    }
    
    if (enableViews[PAGEINDEX_NEXT]) {
        DCPageView *next = [[[DCPageView alloc] initWithFrame:rectForPageView] autorelease];
        [self.pageViews setObject:next forKey:pageID_next];
        [self.contextView addSubview:next];
    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewDidScroll:");
    CGPoint offset = [scrollView contentOffset];
    
    if (offset.x > 0) {
        CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
        CGPoint currentPageViewOffset = [[self currentPageView] frame].origin;
        
        PAGEINDEX index;
        UIViewController *viewCtrl = nil;
        if (offset.x > currentPageViewOffset.x) {
            // current view or next view will appear
            index = PAGEINDEX_NEXT;
            viewCtrl = [self nextViewCtrl];
        } else if (offset.x > prevPageViewOffset.x) {
            // previous view or current view will appsar
            index = PAGEINDEX_PREVIOUS;
            viewCtrl = [self previousViewCtrl];
        } else {
            ;
        }
        
        if (needCallViewWillAppear[index]) {
            [viewCtrl viewWillAppear:YES];
            [self setView:index appearFlag:NO];
        } else if (needCallViewRotate[index]) {
            [viewCtrl shouldAutorotateToInterfaceOrientation:_interfaceOrientation];
            [self setView:index rotateFlag:NO];
        } else {
            ;
        }
        
        if (needCallViewWillAppear[PAGEINDEX_CURRENT]) {
            [[self currentViewCtrl] viewWillAppear:YES];
            [self setView:PAGEINDEX_CURRENT appearFlag:NO];
        } else if (needCallViewRotate[PAGEINDEX_CURRENT]) {
            [[self currentViewCtrl] shouldAutorotateToInterfaceOrientation:_interfaceOrientation];
            [self setView:PAGEINDEX_CURRENT rotateFlag:NO];
        } else {
            ;
        }
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
    scrollViewOffset = [scrollView contentOffset];
    CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
    CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
    if (scrollViewOffset.x == prevPageViewOffset.x) {
        [self previous];
    } else if (scrollViewOffset.x == nextPageViewOffset.x) {
        [self next];
    } else {
        NSLog(@"Warning");
    }
}

- (void)setViewCtrlsWithCurrent:(UIViewController *)current previous:(UIViewController *)previous andNext:(UIViewController *)next {
    if (self.viewCtrls) {
        [self.viewCtrls removeAllObjects];
        
        NSUInteger pageCount = 0;

        if (previous) {
            [self.viewCtrls setObject:previous forKey:pageID_previous];
            [self setView:PAGEINDEX_PREVIOUS appearFlag:YES];
            enableViews[PAGEINDEX_PREVIOUS] = YES;
            ++pageCount;
        }
        if (current) {
            [self.viewCtrls setObject:current forKey:pageID_current];
            [self setView:PAGEINDEX_CURRENT appearFlag:YES];
            enableViews[PAGEINDEX_CURRENT] = YES;
            ++pageCount;
        }
        if (next) {
            [self.viewCtrls setObject:next forKey:pageID_next];
            [self setView:PAGEINDEX_NEXT appearFlag:YES];
            enableViews[PAGEINDEX_NEXT] = YES;
            ++pageCount;
        }
        
        if ([self.pageViews count] != 0 && [self.pageViews count] != pageCount) {
            [self clearUI];
            CGRect rectForScrollView = [self.view bounds];
            self.pageScrollView = [[[UIScrollView alloc] initWithFrame:rectForScrollView] autorelease];
            CGRect rectForContextView;
            rectForContextView.origin = rectForScrollView.origin;
            rectForContextView.size.width = rectForScrollView.size.width * [self.viewCtrls count];
            rectForContextView.size.height = rectForScrollView.size.height;
            self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
            [self.contextView setBackgroundColor:[UIColor clearColor]];
            [self initPageViews];
            [self.pageScrollView addSubview:self.contextView];
            [self.pageScrollView setContentSize:rectForContextView.size];
            self.pageScrollView.scrollEnabled = self.scrollEnabled;
            self.pageScrollView.pagingEnabled = YES;
            self.pageScrollView.bounces = NO;
            [self.pageScrollView setDelegate:self];
            [self.view addSubview:self.pageScrollView];
        }
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
        if (enableViews[PAGEINDEX_PREVIOUS]) {
            [self reloadPageViewWithID:pageID_previous];
        }
        if (enableViews[PAGEINDEX_CURRENT]) {
            [self reloadPageViewWithID:pageID_current];
        }
        if (enableViews[PAGEINDEX_NEXT]) {
            [self reloadPageViewWithID:pageID_next];
        }
        
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
    rectForContextView.size.width = rectForScrollView.size.width * [self.viewCtrls count];
    rectForContextView.size.height = rectForScrollView.size.height;
    self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
    [self.contextView setBackgroundColor:[UIColor clearColor]];
    [self initPageViews];
    
    [self reloadPageViews];
    
    [[self currentViewCtrl] viewWillAppear:animated];
    [self setView:PAGEINDEX_CURRENT appearFlag:NO];
    
    [self.pageScrollView addSubview:self.contextView];
    [self.pageScrollView setContentSize:rectForContextView.size];
    DCPageView *currentPageView = [self currentPageView];
    scrollViewOffset = currentPageView.frame.origin;
    [self.pageScrollView setContentOffset:scrollViewOffset animated:NO];
    self.pageScrollView.scrollEnabled = self.scrollEnabled;
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.bounces = NO;
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
        _interfaceOrientation = interfaceOrientation;
        // do action for interface rotate
        CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
        CGPoint currentPageViewOffset = [[self currentPageView] frame].origin;
        CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
        
        PAGEINDEX index;
        UIViewController *viewCtrl = nil;
        if (scrollViewOffset.x == prevPageViewOffset.x) {
            index = PAGEINDEX_PREVIOUS;
            viewCtrl = [self previousViewCtrl];
        } else if (scrollViewOffset.x == currentPageViewOffset.x) {
            index = PAGEINDEX_CURRENT;
            viewCtrl = [self currentViewCtrl];
        } else if (scrollViewOffset.x == nextPageViewOffset.x) {
            index = PAGEINDEX_NEXT;
            viewCtrl = [self nextViewCtrl];
        } else {
            [NSException raise:@"DCPageScrollViewController error" format:@"scrollViewOffset.x = %d unknown", scrollViewOffset.x];
        }
        
        [self clearUI];
        
        CGRect rectForScrollView = [self.view bounds];
        self.pageScrollView = [[[UIScrollView alloc] initWithFrame:rectForScrollView] autorelease];
        CGRect rectForContextView;
        rectForContextView.origin = rectForScrollView.origin;
        rectForContextView.size.width = rectForScrollView.size.width * [self.viewCtrls count];
        rectForContextView.size.height = rectForScrollView.size.height;
        self.contextView = [[[UIView alloc] initWithFrame:rectForContextView] autorelease];
        [self.contextView setBackgroundColor:[UIColor clearColor]];
        [self initPageViews];
        
        [self reloadPageViews];

        [self setView:PAGEINDEX_PREVIOUS rotateFlag:YES];
        [self setView:PAGEINDEX_CURRENT rotateFlag:YES];
        [self setView:PAGEINDEX_NEXT rotateFlag:YES];
        
        [viewCtrl shouldAutorotateToInterfaceOrientation:interfaceOrientation];
        [self setView:index rotateFlag:NO];
        
        [self.pageScrollView addSubview:self.contextView];
        [self.pageScrollView setContentSize:rectForContextView.size];
        
        DCPageView *pageView = nil;
        if (index == PAGEINDEX_PREVIOUS) {
            pageView = [self previousPageView];
        } else if (index == PAGEINDEX_CURRENT) {
            pageView = [self currentPageView];
        } else {
            pageView = [self nextPageView];
        }
        scrollViewOffset = pageView.frame.origin;
        [self.pageScrollView setContentOffset:scrollViewOffset animated:NO];
        self.pageScrollView.scrollEnabled = self.scrollEnabled;
        self.pageScrollView.pagingEnabled = YES;
        self.pageScrollView.bounces = NO;
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
