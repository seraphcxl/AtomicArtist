//
//  AAItemViewController.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAItemView.h"
#import "AAItemViewCell.h"

@interface AAItemViewController : UITableViewController <AAItemViewDelegate, AAItemViewCellDelegate>

@property (retain, nonatomic) NSString *groupPersistentID;
@property (readonly, nonatomic) NSString *groupTitle;

- (IBAction)refresh:(id)sender;

@end
