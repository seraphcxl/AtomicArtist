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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"DCPageScrollViewController scrollViewDidEndDecelerating:");
    // do action for prev or next
    scrollViewOffset = [scrollView contentOffset];
    CGPoint prevPageViewOffset = [[self previousPageView] frame].origin;
    CGPoint currentPageViewOffset = [[self currentPageView] frame].origin;
    CGPoint nextPageViewOffset = [[self nextPageView] frame].origin;
    DCItemViewController *itemViewCtrl = nil;
    if (scrollViewOffset.x == prevPageViewOffset.x) {
        itemViewCtrl = (DCItemViewController *)[self previousViewCtrl];
    } else if (scrollViewOffset.x == currentPageViewOffset.x) {
        itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    } else if (scrollViewOffset.x == nextPageViewOffset.x) {
        itemViewCtrl = (DCItemViewController *)[self nextViewCtrl];
    } else {
        NSLog(@"Warning");
    }
    
    [self.navigationItem setTitle:itemViewCtrl.groupTitle];
    
    [super scrollViewDidEndDecelerating:scrollView];
}

- (void)selectItem:(NSString *)itemUID {
    DCPageScrollViewController *pageScrollViewCtrl = [[DCPageScrollViewController alloc] initWithNibName:nil bundle:nil];
    DCItemViewController *itemViewCtrl = (DCItemViewController *)[self currentViewCtrl];
    [itemViewCtrl selectItem:itemUID showInPageScrollViewController:pageScrollViewCtrl];
    [self.navigationController pushViewController:pageScrollViewCtrl animated:YES];
}

- (void)itemViewCtrl:(DCItemViewController *)viewCtrl setGroupTitle:(NSString *)title {
    if (title && viewCtrl == [self currentViewCtrl]) {
        [self.navigationItem setTitle:title];
    }
}

@end
