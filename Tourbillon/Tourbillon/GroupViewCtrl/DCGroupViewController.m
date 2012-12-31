//
//  DCGroupViewController.m
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12/31/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCGroupViewController.h"

@interface DCGroupViewController () {
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

@end
