//
//  DCGroupViewCell.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGroupView.h"
#import "DCUniformDataProtocol.h"

@protocol DCGroupViewCellDelegate <NSObject>

- (void)addGroupView:(DCGroupView *)groupView;

- (DCGroupView *)getGroupViewWithDataGroupUID:(NSString *)uid;

@end

@interface DCGroupViewCell : UITableViewCell

@property (assign, nonatomic) id <DCGroupViewCellDelegate> delegate;
@property (assign, nonatomic) id <DCGroupViewDelegate> delegateForGroupView;
@property (readonly, nonatomic) double cellSpace;
@property (readonly, nonatomic) double cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger tableViewMargin;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *dataGroupUIDs;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) id enumDataItemParam;

- (id)initWithDataLibHelper:(id <DCDataLibraryHelper>)dataLibraryHelper dataGroupUIDs:(NSArray *)dataGroupUIDs enumDataItemParam:(id)enumDataItemParam cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
