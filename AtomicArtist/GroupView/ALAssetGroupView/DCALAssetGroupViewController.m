//
//  DCALAssetGroupViewController.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/17/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCALAssetGroupViewController.h"

@interface DCALAssetGroupViewController ()

@end

@implementation DCALAssetGroupViewController

- (void)setEnumDataGroupParam:(id)enumDataGroupParam {
    _enumDataGroupParam = enumDataGroupParam;
}

- (void)setEnumDataItemParam:(id)enumDataItemParam {
    _enumDataItemParam = enumDataItemParam;
}

- (void)dealloc {
    [super dealloc];
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

@end
