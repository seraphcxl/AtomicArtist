//
//  DCGridViewCell.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"


#pragma mark - interface DCGridViewCell : UIView
@interface DCGridViewCell : UIView

@property(nonatomic, strong) UIView *contentView;         // The contentView - default is nil
@property(nonatomic, strong) UIImage *deleteButtonIcon;   // Delete button image
@property(nonatomic) CGPoint deleteButtonOffset;          // Delete button offset relative to the origin
@property(nonatomic, strong) NSString *reuseIdentifier;
@property(nonatomic, getter = isHighlighted) BOOL highlighted;

- (void)prepareForReuse;

@end