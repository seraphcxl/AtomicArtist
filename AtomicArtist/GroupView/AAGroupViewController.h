//
//  AAGroupViewController.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAGroupViewCell.h"

@interface AAGroupViewController : UITableViewController <AAGroupViewDelegate, AAGroupViewCellDelegate>

@property (assign, nonatomic) ALAssetsGroupType assetsGroupType;

- (IBAction)refresh:(id)sender;

@end
