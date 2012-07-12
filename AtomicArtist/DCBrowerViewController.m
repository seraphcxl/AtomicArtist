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
        UIViewController *viewCtrl = [self.viewControllers lastObject];
        if ([viewCtrl isMemberOfClass:[DCGroupViewController class]]) {
            DCGroupViewController *groupViewCtrl = (DCGroupViewController *)viewCtrl;
            [groupViewCtrl clearOperations];
        } else if ([viewCtrl isMemberOfClass:[DCItemPageScrollViewController class]]) {
            DCItemPageScrollViewController *itemPageScrollViewCtrl = (DCItemPageScrollViewController *)viewCtrl;
            [itemPageScrollViewCtrl clearOperations];
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
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"DCBrowerViewController error" format:@"Reason: Current device type unknown"];
    }
    return result;
}

@end
