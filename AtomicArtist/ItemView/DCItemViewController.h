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
#import "DCPageScrollViewController.h"

@interface DCItemViewController : UITableViewController <DCItemViewCellDelegate, DCPageScrollViewControllerDelegate>

@property (assign, nonatomic) id <DCItemViewDelegate> delegateForItemView;
@property (retain, nonatomic) NSString *dataGroupUID;
@property (assign, nonatomic) NSUInteger dataGroupIndex;
@property (readonly, nonatomic) NSString *groupTitle;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) id enumDataItemParam;

- (IBAction)refresh:(id)sender;

- (id)initWithDataLibraryHelper:(id <DCDataLibraryHelper>)dataLibraryHelper;

- (void)selectItem:(NSString *)itemUID showInPageScrollViewController:(DCPageScrollViewController *)pageScrollViewCtrl;

@end
