//
//  DCPetalAnimationStrategies.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCPetalAnimationStrategies.h"

@interface DCPetalAnimationStrategyFactory () {
}

@end

@implementation DCPetalAnimationStrategyFactory

+ (id<DCPetalAnimationStrategy>)strategyFromType:(DCPetalAnimationStrategyType)type {
    id<DCPetalAnimationStrategy> result = nil;
    do {
        @synchronized(self) {
        }
    } while (NO);
    return result;
}

@end

@interface DCPetalAnimationStrategyBase () {
}

@end

@implementation DCPetalAnimationStrategyBase

@synthesize animationDuration = _animationDuration;

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _animationDuration = 0.0f;
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _animationDuration = 0.0f;
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)actionForBloom:(DCPetalView *)petal {
    do {
        ;
    } while (NO);
}

- (void)actionForWither:(DCPetalView *)petal {
    do {
        ;
    } while (NO);
}

@end
