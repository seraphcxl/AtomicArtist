//
//  DCSpotlight.h
//  Helius
//
//  Created by Chen XiaoLiang on 13-3-27.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCSpotlight : NSObject

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) UIColor *gradientColor;
@property (nonatomic, readonly) CGGradientRef spotlightGradientRef;

- (id)initWithGradientColor:(UIColor *)aGradientColor;

@end

@interface DCRadialSpotlight : DCSpotlight

@property (nonatomic, assign) CGPoint centerAnchor;
@property (nonatomic, assign) float spotlightRadius;
@property (nonatomic, assign) float gradientRadius;

@end

@interface DCRectSpotlight : DCSpotlight

@property (nonatomic, assign) CGRect rectangle;

@end
