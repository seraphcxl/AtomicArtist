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

- (void)dataFirstScreenRefreshFinished:(NSNotification *)note;

- (void)showRefreshingMask;
- (void)hideRefreshingMask;

@end

@implementation DCItemPageScrollViewController

- (void)showRefreshingMask {
    do {
        [self.navigationItem setHidesBackButton:YES animated:NO];
        
        UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [activityIndicatorView startAnimating];
        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView] autorelease];
        [self.navigationItem setRightBarButtonItem:bbi];
        
        UIActivityIndicatorView *activityIndicatorViewForScreen = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        [activityIndicatorViewForScreen setFrame:[self.view frame]];
        //        [activityIndicatorViewForScreen setBackgroundColor:[UIColor blackColor]];
        //        [activityIndicatorViewForScreen setAlpha:0.25];
        [activityIndicatorViewForScreen startAnimating];
        [self.view addSubview:activityIndicatorViewForScreen];
        
    } while (NO);
}

- (void)hideRefreshingMask {
    do {
        [self.navigationItem setHidesBackButton:NO animated:NO];
        
        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
        [self.navigationItem setRightBarButtonItem:bbi];
        
        for (UIView *view in [self.view subviews]) {
            if ([view isMemberOfClass:[UIActivityIndicatorView class]]) {
                [view removeFromSuperview];
            }
        }
        
    } while (NO);
}

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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(dataFirstScreenRefreshFinished:) name:NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END object:nil];
    
    [self performSelectorOnMainThread:@selector(showRefreshingMask) withObject:nil waitUntilDone:NO];

}

- (void)viewDidUnload
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (IBAction)refresh:(id)sender {
    [self performSelectorOnMainThread:@selector(showRefreshingMask) withObject:nil waitUntilDone:NO];
    
    DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    [itemViewCtrl refresh:sender];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    debug_NSLog(@"DCPageScrollViewController scrollViewDidScroll:");
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
        debug_NSLog(@"Warning");
    }
    
    if (itemViewCtrl) {
        [self.navigationItem setTitle:itemViewCtrl.groupTitle];
    }
    
    [super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    debug_NSLog(@"DCPageScrollViewController scrollViewDidEndDecelerating:");
    
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
    [self performSelectorOnMainThread:@selector(showRefreshingMask) withObject:nil waitUntilDone:NO];
}

- (void)dataRefreshFinished {
    [self performSelectorOnMainThread:@selector(hideRefreshingMask) withObject:nil waitUntilDone:NO];
}

- (void)popFormNavigationCtrl {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemViewCtrl:(DCItemViewController *)viewCtrl setGroupTitle:(NSString *)title {
    if (title && viewCtrl == [self currentViewCtrl]) {
        [self.navigationItem setTitle:title];
    }
}

- (void)clearOperations {
    do {
        DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
        if (itemViewCtrl) {
            [itemViewCtrl clearOperations];
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

- (void)dataFirstScreenRefreshFinished:(NSNotification *)note {
    debug_NSLog(@"DCItemPageScrollViewController dataFirstScreenRefreshFinished:");
    if ([self.navigationController topViewController] == self) {
        DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
        if (itemViewCtrl) {
            [itemViewCtrl dataFirstScreenRefreshFinished:note];
        }
    }
}

@end
