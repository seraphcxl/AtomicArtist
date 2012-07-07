//
//  DCItemViewCell.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCItemView.h"
#import "DCUniformDataProtocol.h"

@protocol DCItemViewCellDelegate <NSObject>

//- (void)addItemView:(DCItemView *)itemView;
//
//- (DCItemView *)getItemViewWithItemUID:(NSString *)itemUID;

@end

@interface DCItemViewCell : UITableViewCell

@property (assign, nonatomic) id <DCItemViewCellDelegate> delegate;
@property (readonly, nonatomic) double cellSpace;
@property (readonly, nonatomic) double cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger tableViewMargin;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *dataItemViews;

- (id)initWithDataItemViews:(NSArray *)dataItemViews cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
