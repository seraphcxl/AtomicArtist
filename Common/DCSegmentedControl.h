//
//  DCSegmentedControl.h
//
//
//  Created by Chen XiaoLiang on 13-1-5.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@protocol DCSegmentedControlDelegate <NSObject>

- (void)valueChanged:(NSUInteger)index;

@end

@interface DCSegmentedControl : UIView {
}

@property (nonatomic, assign) id<DCSegmentedControlDelegate> delegate;

@property (nonatomic, readonly) NSUInteger divisionWidth;
@property (nonatomic, readonly) NSUInteger segmentWidth;
@property (nonatomic, readonly) NSUInteger segmentCount;

@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImage *divisioImageForUnselected;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImage *divisioImageForLeftSelected;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIImage *divisioImageForRightSelected;

@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *divisioColorForUnselected;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *divisioColorForLeftSelected;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *divisioColorForRightSelected;

- (id)initWithFrame:(CGRect)frame segmentCount:(NSUInteger)segmentCount edgeInsets:(UIEdgeInsets)edgeInsets andMinDivisionWidth:(NSUInteger)minDivisionWidth;

- (void)setBackgroundImage:(UIImage *)aImage;
- (void)setBackgroundViewColor:(UIColor *)aColor;

- (void)setDefultselectedSegment:(NSUInteger)index;

- (UIButton *)SegmentAtIndex:(NSUInteger)index;

- (void)customizeSegmentAtIndex:(NSUInteger)index withTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color forState:(UIControlState)state;

- (void)customizeSegmentAtIndex:(NSUInteger)index withImage:(UIImage *)image forState:(UIControlState)state;

@end
