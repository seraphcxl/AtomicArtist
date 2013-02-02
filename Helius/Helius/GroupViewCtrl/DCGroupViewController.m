//
//  DCGroupViewController.m
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12/31/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCGroupViewController.h"
#import "DCALAssetsGroupView.h"

@interface DCGroupViewController () <DCGridViewDataSource, DCGridViewDragDropDelegate, DCGridViewTransformationDelegate, DCGridViewActionDelegate, UIScrollViewDelegate> {
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
- (NSInteger)numberOfItemsInGridView:(DCGridView *)gridView {
    NSInteger result = 0;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (CGSize)gridView:(DCGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize result = CGSizeZero;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (DCGridViewCell *)gridView:(DCGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    DCGridViewCell *result = nil;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

- (BOOL)gridView:(DCGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    BOOL result = NO;
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark - DCGroupViewController - DCGridViewDragDropDelegate
- (BOOL)isEnableDragDrop {
    return YES;
}

- (DCGridViewDragDropStyle)dragdropStyle {
    return DCGridViewDragDropStyle_Swap;
}

- (void)gridView:(DCGridView *)gridView dragdropStateBegin:(DCGridViewCell *)cell withGestureRecognizer:(UIGestureRecognizer *)gr {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView dragdropStateChanged:(DCGridViewCell *)cell withGestureRecognizer:(UIGestureRecognizer *)gr {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView dragdropStateEnd:(DCGridViewCell *)cell withGestureRecognizer:(UIGestureRecognizer *)gr {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView dragdropStateCancelledWithGestureRecognizer:(UIGestureRecognizer *)gr {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView dragdropStateFailedWithGestureRecognizer:(UIGestureRecognizer *)gr {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView didStartMovingCell:(DCGridViewCell *)cell {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (void)gridView:(DCGridView *)gridView didEndMovingCell:(DCGridViewCell *)cell {
    do {
        if (gridView != self.gridView) {
            break;
        }
    } while (NO);
}

- (BOOL)gridView:(DCGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(DCGridViewCell *)view atIndex:(NSInteger)index {
    BOOL result = NO;
    do {
        if (gridView != self.gridView) {
            break;
        }
        result = YES;
    } while (NO);
    return result;
}

#pragma mark - DCGroupViewController - DCGridViewTransformationDelegate
- (CGSize)gridView:(DCGridView *)gridView sizeInFullSizeForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize result = CGSizeZero;
    do {
        if (gridView != self.gridView || !cell) {
            break;
        }
    } while (NO);
    return result;
}

- (UIView *)gridView:(DCGridView *)gridView fullSizeViewForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index {
    UIView *result = nil;
    do {
        if (gridView != self.gridView || !cell) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark - DCGroupViewController - DCGridViewActionDelegate
- (void)gridView:(DCGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
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
