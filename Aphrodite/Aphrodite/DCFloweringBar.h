//
//  DCFloweringBar.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@class DCBudView;
@class DCPetalView;
@class DCDewView;

@interface DCFloweringBar : NSObject {
}

@property (nonatomic, readonly) CGPoint anchor;  // The anchor point for flowering bar.
@property (nonatomic, SAFE_ARC_PROP_WEAK) UIView *floweringBranchView;  // A view that flowering bar lay on.
@property (nonatomic, SAFE_ARC_PROP_STRONG) DCBudView *budView;  // The central bud view.

- (id)initWithAnchor:(CGPoint)aAnchor andFloweringBranch:(UIView *)aFloweringBranchView;

// Petal
- (DCPetalView *)getPetal:(CGFloat)angle;

// Dew
- (DCDewView *)getDew:(CGFloat)radius onPetal:(CGFloat)angle;

- (void)addDew:(DCDewView *)aDewView atPetal:(DCPetalView *)aPetalView;
- (void)addDew:(DCDewView *)aDewView atAngle:(CGFloat)angle;

@end
