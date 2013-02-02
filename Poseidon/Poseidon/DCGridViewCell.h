//
//  DCGridViewCell.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

#pragma mark - protocol DCGridViewCellDragDropDataSource <NSObject>
@protocol DCGridViewCellDragDropDataSource <NSObject>

- (NSString *)uniqueID;
- (id)originDataSource;
- (CGImageRef)image;

@end

#pragma mark - interface DCGridViewCell : UIView
@interface DCGridViewCell : UIView

@property (nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet NSObject<DCGridViewCellDragDropDataSource> *dragdropDataSource;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *contentView;         // The contentView - default is nil
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImage *deleteButtonIcon;   // Delete button image
@property (nonatomic) CGPoint deleteButtonOffset;          // Delete button offset relative to the origin
@property (nonatomic, SAFE_ARC_PROP_STRONG) NSString *reuseIdentifier;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;

- (void)prepareForReuse;

@end
