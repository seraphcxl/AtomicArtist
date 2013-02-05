//
//  DCPetalAnimationStrategies.h
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
    DCPetalAnimation_Fade = 0,
    DCPetalAnimation_Rotate,
} DCPetalAnimationStrategyType;

@class DCPetalView;

@protocol DCPetalAnimationStrategy <NSObject>

- (void)actionForBloom:(DCPetalView *)petal;
- (void)actionForWither:(DCPetalView *)petal;

@end

@interface DCPetalAnimationStrategyFactory : NSObject

+ (id<DCPetalAnimationStrategy>)strategyFromType:(DCPetalAnimationStrategyType)type;

@end

@interface DCPetalAnimationStrategyBase : NSObject <DCPetalAnimationStrategy> {
}

@property (nonatomic, assign) CFTimeInterval animationDuration;

@end
