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
#import "DCPageScrollViewController.h"

enum GROUPVIEWCTRL_TYPE {
    GROUPVIEWCTRL_TYPE_ALASSET = 0,
};

@interface DCGroupViewController : UITableViewController <DCGroupViewDelegate, DCGroupViewCellDelegate, DCPageScrollViewControllerDelegate> {
    id _enumDataGroupParam;
    id _enumDataItemParam;
}

@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) enum GROUPVIEWCTRL_TYPE type;

- (IBAction)refresh:(id)sender;

- (id)initWithDataLibHelper:(id <DCDataLibraryHelper>)dataLibraryHelper;

- (void)setEnumDataGroupParam:(id)enumDataGroupParam;
- (void)setEnumDataItemParam:(id)enumDataItemParam;

@end
