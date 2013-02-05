//
//  DCDewButton.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCDewAnimationStrategies.h"
#import "DCDewLayoutStrategies.h"

@protocol DCDewButtonAngleDelegate <NSObject>

- (CGFloat)angle;

@end

@protocol DCDewButtonAnchorDelegate <NSObject>

- (CGFloat)anchor;

@end

@interface DCDewButton : UIButton {
}

@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCDewButtonAnchorDelegate> anchorDelegate;
@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCDewButtonAngleDelegate> angleDelegate;

@property (nonatomic, SAFE_ARC_PROP_STRONG) id<DCDewAnimationStrategy> animationStrategy;
@property (nonatomic, SAFE_ARC_PROP_STRONG) id<DCDewLayoutStrategy> layoutStrategy;

@property (nonatomic, assign) CGFloat radius;

+ (NSString *)uniqueIDForRadius:(CGFloat)radius;
- (NSString *)uniqueID;

@end
