//
//  AAGroupViewCell.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAGroupView.h"

@protocol AAGroupViewCellDelegate <NSObject>

- (void)addGroupView:(AAGroupView *)groupView;

- (AAGroupView *)getGroupViewWithGroupPersistentID:(NSString *)groupPersistentID;

@end

@interface AAGroupViewCell : UITableViewCell

@property (assign, nonatomic) id <AAGroupViewCellDelegate> delegate;
@property (assign, nonatomic) id <AAGroupViewDelegate> delegateForGroupView;
@property (readonly, nonatomic) NSUInteger cellSpace;
@property (readonly, nonatomic) NSUInteger cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *groupPersistentIDs;

- (id)initWithGroupPersistentIDs:(NSArray *)groupPersistentIDs cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
