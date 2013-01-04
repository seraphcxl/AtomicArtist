//
//  DCGroupViewController.m
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12/31/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCGroupViewController.h"
#import "DCALAssetsGroupView.h"

@interface DCGroupViewController () <DCGridViewDataSource, DCGridViewSortingDelegate, DCGridViewTransformationDelegate, DCGridViewActionDelegate, UIScrollViewDelegate> {
}

@end

@implementation DCGroupViewController

@synthesize gridView = _gridView;
@synthesize dataLib = _dataLib;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger result = UIInterfaceOrientationPortrait;
    do {
        ;
    } while (NO);
    return result;
}

#else
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL result = NO;
    do {
        ;
    } while (NO);
    return result;
}
#endif

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    do {
        ;
    } while (NO);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    do {
        ;
    } while (NO);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    do {
        ;
    } while (NO);
}

- (void)viewWillDisappear:(BOOL)animated {
    do {
        ;
    } while (NO);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    do {
        self.gridView = nil;
        
        if (_dataLib) {
            [_dataLib disconnect];
            SAFE_ARC_SAFERELEASE(_dataLib);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

#pragma mark - DCGroupViewController - DCGridViewDataSource
- (NSInteger)numberOfItemsInDCGridView:(DCGridView *)gridView {
    NSInteger result = 0;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (CGSize)DCGridView:(DCGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize result = CGSizeZero;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (DCGridViewCell *)DCGridView:(DCGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    DCGridViewCell *result = nil;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (BOOL)DCGridView:(DCGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    BOOL result = NO;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark - DCGroupViewController - DCGridViewSortingDelegate
- (void)DCGridView:(DCGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)DCGridView:(DCGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

#pragma mark - DCGroupViewController - DCGridViewTransformationDelegate
- (CGSize)DCGridView:(DCGridView *)gridView sizeInFullSizeForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize result = CGSizeZero;
    do {
        if (gridView != self.gridView || !cell) {
            break;
        }
    } while (NO);
    return result;
}

- (UIView *)DCGridView:(DCGridView *)gridView fullSizeViewForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index {
    UIView *result = nil;
    do {
        if (gridView != self.gridView || !cell) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark - DCGroupViewController - DCGridViewActionDelegate
- (void)DCGridView:(DCGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

#pragma mark - DCGroupViewController - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    do {
        if (scrollView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    do {
        if (scrollView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    do {
        if (scrollView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    do {
        if (scrollView != self.gridView) {
            break;
        }
    } while (NO);
}

@end
