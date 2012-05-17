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

- (void)addItemView:(DCItemView *)itemView;

- (DCItemView *)getItemViewWithItemUID:(NSString *)itemUID;

@end

@interface DCItemViewCell : UITableViewCell

@property (assign, nonatomic) id <DCItemViewCellDelegate> delegate;
@property (assign, nonatomic) id <DCItemViewDelegate> delegateForItemView;
@property (readonly, nonatomic) NSUInteger cellSpace;
@property (readonly, nonatomic) NSUInteger cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *itemUIDs;
@property (readonly, nonatomic) NSString *dataGroupUID;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;

- (id)initWithDataLibraryHelper:(id <DCDataLibraryHelper>)dataLibraryHelper itemUIDs:(NSArray *)itemUIDs dataGroupUID:(NSString *)dataGroupUID cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
