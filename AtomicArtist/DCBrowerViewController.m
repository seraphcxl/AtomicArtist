//
//  DCBrowerViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCBrowerViewController.h"
#import "DCGroupViewController.h"
#import "DCItemPageScrollViewController.h"

@interface DCBrowerViewController ()

@end

@implementation DCBrowerViewController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *result = nil;
    do {
        BOOL needTerminateAllOperations = NO;
        UIViewController *viewCtrl = [self.viewControllers lastObject];
        if ([viewCtrl isMemberOfClass:[DCGroupViewController class]]) {
            DCGroupViewController *groupViewCtrl = (DCGroupViewController *)viewCtrl;
            [groupViewCtrl actionForWillDisappear];
            needTerminateAllOperations = YES;
        } else if ([viewCtrl isMemberOfClass:[DCItemPageScrollViewController class]]) {
            DCItemPageScrollViewController *itemPageScrollViewCtrl = (DCItemPageScrollViewController *)viewCtrl;
            [itemPageScrollViewCtrl actionForWillDisappear];
            needTerminateAllOperations = YES;
        }
        if (needTerminateAllOperations) {
            [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
            [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        }
        result = [super popViewControllerAnimated:animated];
    } while (NO);
    return result;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
