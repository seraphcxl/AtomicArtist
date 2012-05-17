//
//  DCItemViewCell.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCItemView.h"

@protocol DCItemViewCellDelegate <NSObject>

- (void)addItemView:(DCItemView *)itemView;

- (DCItemView *)getItemViewWithAssetURL:(NSURL *)assetURL;

@end

@interface DCItemViewCell : UITableViewCell

@property (assign, nonatomic) id <DCItemViewCellDelegate> delegate;
@property (assign, nonatomic) id <DCItemViewDelegate> delegateForItemView;
@property (readonly, nonatomic) NSUInteger cellSpace;
@property (readonly, nonatomic) NSUInteger cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *assetURLs;
@property (readonly, nonatomic) NSString *groupPersistentID;

- (id)initWithAssetURLs:(NSArray *)assetURLs groupPersistentID:(NSString *)groupPersistentID cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
