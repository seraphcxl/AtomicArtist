//
//  DCDewLayoutStrategies.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

typedef enum {
    DCDewLayout_Vertically = 0,
    DCDewLayout_FixPetal,
} DCDewLayoutStrategyType;

@class DCDewButton;

@protocol DCDewLayoutStrategy <NSObject>

- (void)layout:(DCDewButton *)dew withAngle:(CGFloat)angle;

@end

@interface DCDewLayoutStrategyFactory : NSObject

+ (id<DCDewLayoutStrategy>)strategyFromType:(DCDewLayoutStrategyType)type;

@end

@interface DCDewLayoutStrategyBase : NSObject <DCDewLayoutStrategy> {
}

@property (nonatomic, assign, getter = isRotate) BOOL rotate;

@property (nonatomic, assign) CFTimeInterval animationDuration;

@end
