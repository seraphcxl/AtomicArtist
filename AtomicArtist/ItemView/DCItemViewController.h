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
#import "DCUniformDataProtocol.h"

@interface DCItemViewController : UITableViewController <DCItemViewDelegate, DCItemViewCellDelegate>

@property (retain, nonatomic) NSString *dataGroupUID;
@property (readonly, nonatomic) NSString *groupTitle;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) id enumDataItemParam;

- (IBAction)refresh:(id)sender;

- (id)initWithDataLibraryHelper:(id <DCDataLibraryHelper>)dataLibraryHelper;

@end
