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
#import "DCItemViewCache.h"

@class DCItemViewController;

@protocol DCItemViewControllerDelegate <NSObject>

- (void)itemViewCtrl:(DCItemViewController *)viewCtrl setGroupTitle:(NSString *)title;
- (void)popFormNavigationCtrl;
- (void)dataRefreshStarted;
- (void)dataRefreshFinished;

@end

@interface DCItemViewController : UITableViewController <DCItemViewCellDelegate, DCPageScrollViewControllerDelegate, DCViewCacheDelegate>

@property (assign, nonatomic) id<DCItemViewControllerDelegate> delegate;
@property (assign, nonatomic) id<DCItemViewDelegate> delegateForItemView;
@property (retain, nonatomic) NSString *dataGroupUID;
@property (assign, nonatomic) NSUInteger dataGroupIndex;
@property (readonly, nonatomic) NSString *groupTitle;
@property (assign, nonatomic) id<DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) id enumDataItemParam;

@property (readonly, nonatomic) DCItemViewCache *viewCache;

- (IBAction)refresh:(id)sender;

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper;

- (void)selectItem:(NSString *)itemUID showInPageScrollViewController:(DCPageScrollViewController *)pageScrollViewCtrl;

- (void)clearOperations;
- (void)actionForDidUnload;

- (void)dataFirstScreenRefreshFinished:(NSNotification *)note;

@end
