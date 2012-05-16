//
//  AAItemViewCell.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAItemView.h"

@protocol AAItemViewCellDelegate <NSObject>

- (void)addItemView:(AAItemView *)itemView;

- (AAItemView *)getItemViewWithAssetURL:(NSURL *)assetURL;

@end

@interface AAItemViewCell : UITableViewCell

@property (assign, nonatomic) id <AAItemViewCellDelegate> delegate;
@property (assign, nonatomic) id <AAItemViewDelegate> delegateForItemView;
@property (readonly, nonatomic) NSUInteger cellSpace;
@property (readonly, nonatomic) NSUInteger cellTopBottomMargin;
@property (readonly, nonatomic) NSUInteger frameSize;
@property (readonly, nonatomic) NSUInteger itemCount;
@property (retain, nonatomic) NSArray *assetURLs;
@property (readonly, nonatomic) NSString *groupPersistentID;

- (id)initWithAssetURLs:(NSArray *)assetURLs groupPersistentID:(NSString *)groupPersistentID cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount;

@end
