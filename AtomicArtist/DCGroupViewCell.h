//
//  DCGroupViewCell.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGroupView.h"

@protocol DCGroupViewCellDelegate <NSObject>

- (void)addGroupView:(DCGroupView *)groupView;

- (DCGroupView *)getGroupViewWithGroupPersistentID:(NSString *)groupPersistentID;

@end

@interface DCGroupViewCell : UITableViewCell

@property (assign, nonatomic) id <DCGroupViewCellDelegate> delegate;
@property (assign, nonatomic) id <DCGroupViewDelegate> delegateForGroupView;
@property (readonly, nonatomic) NSUInteger cellSpace;
@property (readonly, nonatomic) NSUInteger cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *groupPersistentIDs;

- (id)initWithGroupPersistentIDs:(NSArray *)groupPersistentIDs cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
