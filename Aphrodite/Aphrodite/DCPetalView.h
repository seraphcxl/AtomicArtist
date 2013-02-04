//
//  DCPetalView.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@protocol DCPetalViewAnchorDelegate <NSObject>

- (CGFloat)anchor;

@end

@class DCDewButton;

@interface DCPetalView : UIView {
}

@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCPetalViewAnchorDelegate> anchorDelegate;

@property (nonatomic, assign) CGFloat angle;

+ (NSString *)uniqueIDForAngle:(CGFloat)angle;
- (NSString *)uniqueID;

// Dew
- (DCDewButton *)getDew:(CGFloat)radius;

- (void)addDew:(DCDewButton *)aDewButton;

@end
