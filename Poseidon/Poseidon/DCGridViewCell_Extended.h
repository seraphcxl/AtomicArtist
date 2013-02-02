//
//  DCGridViewCell_Extended.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "DCGridViewCell.h"
#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"

typedef void (^DCGridViewCellDeleteBlock)(DCGridViewCell *);


#pragma mark - interface DCGridViewCell ()
@interface DCGridViewCell () {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG) UIView *fullSizeView;
@property (nonatomic, assign) CGSize fullSize;

@property (nonatomic, readonly, getter = isInShakingMode) BOOL inShakingMode;
@property (nonatomic, readonly, getter = isInFullSizeMode) BOOL inFullSizeMode;

@property (nonatomic, getter = isEditing) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@property (nonatomic, copy) DCGridViewCellDeleteBlock deleteBlock;

@property (nonatomic, assign) UIViewAutoresizing defaultFullsizeViewResizingMask;
@property (nonatomic, SAFE_ARC_PROP_WEAK) UIButton *deleteButton;

- (void)prepareForReuse;
- (void)shake:(BOOL)on; // shakes the contentView only, not the fullsize one

- (void)switchToFullSizeMode:(BOOL)fullSizeEnabled;
- (void)stepToFullsizeWithAlpha:(CGFloat)alpha; // not supported yet

@end
