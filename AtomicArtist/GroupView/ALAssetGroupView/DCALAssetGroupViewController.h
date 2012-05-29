//
//  DCALAssetGroupViewController.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/17/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCGroupViewController.h"

@interface DCALAssetGroupViewController : DCGroupViewController

@property (retain, nonatomic) IBOutlet UISegmentedControl *sourceSwitch;

- (IBAction)sourceSwitchValueChanged:(id)sender;

@end
