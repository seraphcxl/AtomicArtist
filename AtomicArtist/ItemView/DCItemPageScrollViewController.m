//
//  DCItemPageScrollViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCItemPageScrollViewController.h"
#import "DCItemViewController.h"

@interface DCItemPageScrollViewController ()

@end

@implementation DCItemPageScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (IBAction)refresh:(id)sender {
    DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    [itemViewCtrl refresh:sender];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewDidScroll:");
    scrollViewOffset = [scrollView contentOffset];
    CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
    CGPoint currentPageViewOffset = [[self currentPageView] frame].origin;
    CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
    DCItemViewController *itemViewCtrl = nil;
    
    CGFloat centerOfPrevAndCurrent = (prevPageViewOffset.x + currentPageViewOffset.x) / 2.0;
    CGFloat centerOfCurrentAndNext = (currentPageViewOffset.x + nextPageViewOffset.x) / 2.0;
    
    if ([self previousViewCtrl] && scrollViewOffset.x < centerOfPrevAndCurrent) {
        itemViewCtrl = (DCItemViewController *)[self previousViewCtrl];
    } else if ([self currentViewCtrl] && scrollViewOffset.x >= centerOfPrevAndCurrent && scrollViewOffset.x < centerOfCurrentAndNext) {
        itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    } else if ([self nextViewCtrl] && scrollViewOffset.x >= centerOfCurrentAndNext) {
        itemViewCtrl = (DCItemViewController *)[self nextViewCtrl];
    } else {
        NSLog(@"Warning");
    }
    
    if (itemViewCtrl) {
        [self.navigationItem setTitle:itemViewCtrl.groupTitle];
    }
    
    [super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewDidEndDecelerating:");
    // do action for prev or next
//    scrollViewOffset = [scrollView contentOffset];
//    CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
//    CGPoint currentPageViewOffset = [[self currentPageView] frame].origin;
//    CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
//    DCItemViewController *itemViewCtrl = nil;
//    if ([self previousViewCtrl] && scrollViewOffset.x == prevPageViewOffset.x) {
//        itemViewCtrl = (DCItemViewController *)[self previousViewCtrl];
//    } else if ([self currentViewCtrl] && scrollViewOffset.x == currentPageViewOffset.x) {
//        itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
//    } else if ([self nextViewCtrl] && scrollViewOffset.x == nextPageViewOffset.x) {
//        itemViewCtrl = (DCItemViewController *)[self nextViewCtrl];
//    } else {
//        NSLog(@"Warning");
//    }
//    
//    [self.navigationItem setTitle:itemViewCtrl.groupTitle];
    
    [super scrollViewDidEndDecelerating:scrollView];
}

- (void)selectItem:(NSString *)itemUID {
    DCPageScrollViewController *pageScrollViewCtrl = [[[DCPageScrollViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    NSInteger index = -1;
    index = [itemViewCtrl.dataLibraryHelper indexForItemUID:itemUID inGroup:itemViewCtrl.dataGroupUID];
    if (index == -1) {
        [NSException raise:@"DCPageScrollViewController error" format:@"item:%@ not find", itemUID];
//        itemViewCtrl = (DCItemViewController *)[self previousViewCtrl];
//        index = [itemViewCtrl.dataLibraryHelper indexForItemUID:itemUID inGroup:itemViewCtrl.dataGroupUID];
//        if (index == -1) {
//            itemViewCtrl = (DCItemViewController *)[self nextViewCtrl];
//            index = [itemViewCtrl.dataLibraryHelper indexForItemUID:itemUID inGroup:itemViewCtrl.dataGroupUID];
//            if (index == -1) {
//                
//            }
//        }
    }
    [itemViewCtrl selectItem:itemUID showInPageScrollViewController:pageScrollViewCtrl];
    [self.navigationController pushViewController:pageScrollViewCtrl animated:NO];
}

- (void)dataRefreshStarted {
    [self.navigationItem setRightBarButtonItem:nil];
    /// /// ///
    [self.navigationItem setHidesBackButton:YES animated:NO];
    /// /// ///
//    UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
//    [activityIndicatorView setFrame:[self.view frame]];
//    [self.view addSubview:activityIndicatorView];
//    [activityIndicatorView startAnimating];
}

- (void)dataRefreshFinished {
    UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    [self.navigationItem setRightBarButtonItem:bbi];
    /// /// ///
    [self.navigationItem setHidesBackButton:NO animated:NO];
    /// /// ///
//    for (UIView *view in [self.view subviews]) {
//        if ([view isMemberOfClass:[UIActivityIndicatorView class]]) {
//            UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)view;
//            [activityIndicatorView stopAnimating];
//            [activityIndicatorView removeFromSuperview];
//        }
//    }
}

- (void)popFormNavigationCtrl {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemViewCtrl:(DCItemViewController *)viewCtrl setGroupTitle:(NSString *)title {
    if (title && viewCtrl == [self currentViewCtrl]) {
        [self.navigationItem setTitle:title];
    }
}

- (void)actionForWillDisappear {
    do {
        DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
        if (itemViewCtrl) {
            [itemViewCtrl actionForWillDisappear];
        }
    } while (NO);
}

- (void)actionForDidUnload {
    do {
        DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
        if (itemViewCtrl) {
            [itemViewCtrl actionForDidUnload];
        }
    } while (NO);
}

@end
