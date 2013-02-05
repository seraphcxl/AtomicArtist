//
//  DCDewAnimationStrategies.h
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
    DCDewAnimation_Fade = 0,
    DCDewAnimation_Path,
} DCDewAnimationStrategyType;

@class DCDewButton;

@protocol DCDewAnimationStrategy <NSObject>

- (void)actionForBloom:(DCDewButton *)dew;
- (void)actionForDrop:(DCDewButton *)dew;

@end

@interface DCDewAnimationStrategyFactory : NSObject

+ (id<DCDewAnimationStrategy>)strategyFromType:(DCDewAnimationStrategyType)type;

@end

@interface DCDewAnimationStrategyBase : NSObject <DCDewAnimationStrategy> {
}

@property (nonatomic, assign) CFTimeInterval animationDuration;

@end
