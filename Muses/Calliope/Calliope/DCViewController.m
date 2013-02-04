//
//  DCViewController.m
//  Calliope
//
//  Created by Chen XiaoLiang on 13-1-29.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCViewController.h"
#import "DCFloweringBar.h"

@interface DCViewController ()

@end

@implementation DCViewController

@synthesize floweringBar = _floweringBar;

- (id)init {
    self = [super init];
    if (self) {
        _floweringBar = [[DCFloweringBar alloc] initWithAnchor:CGPointZero andFloweringBranch:self.view];
        SAFE_ARC_AUTORELEASE(_floweringBar);
    }
    return self;
}

- (void)viewDidLoad
{
    do {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    } while (NO);
}

- (void)viewWillAppear:(BOOL)animated {
    do {
        [super viewWillAppear:animated];
    } while (NO);
}

- (void)viewWillDisappear:(BOOL)animated {
    do {
        [super viewWillDisappear:animated];
    } while (NO);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
