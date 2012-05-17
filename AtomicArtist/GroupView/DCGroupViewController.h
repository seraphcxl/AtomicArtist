//
//  DCGroupViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGroupViewCell.h"
#import "DCUniformDataProtocol.h"

@interface DCGroupViewController : UITableViewController <DCGroupViewDelegate, DCGroupViewCellDelegate>

@property (assign, nonatomic) id enumDataGroupParam;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;

- (IBAction)refresh:(id)sender;

- (id)initWithDataLibHelper:(id <DCDataLibraryHelper>)dataLibraryHelper;

@end
