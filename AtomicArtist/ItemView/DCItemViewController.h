//
//  DCItemViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCItemView.h"
#import "DCItemViewCell.h"

@interface DCItemViewController : UITableViewController <DCItemViewDelegate, DCItemViewCellDelegate>

@property (retain, nonatomic) NSString *groupPersistentID;
@property (readonly, nonatomic) NSString *groupTitle;

- (IBAction)refresh:(id)sender;

@end
