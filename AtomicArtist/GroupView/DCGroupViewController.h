//
//  DCGroupViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGroupViewCell.h"

@interface DCGroupViewController : UITableViewController <DCGroupViewDelegate, DCGroupViewCellDelegate>

@property (assign, nonatomic) ALAssetsGroupType assetsGroupType;

- (IBAction)refresh:(id)sender;

@end
