//
//  DCDewAnimationStrategies.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCDewAnimationStrategies.h"

@interface DCDewAnimationStrategyFactory () {
}

@end

@implementation DCDewAnimationStrategyFactory

+ (id<DCDewAnimationStrategy>)strategyFromType:(DCDewAnimationStrategyType)type {
    id<DCDewAnimationStrategy> result = nil;
    do {
        @synchronized(self) {
        }
    } while (NO);
    return result;
}

@end

@interface DCDewAnimationStrategyBase () {
}

@end

@implementation DCDewAnimationStrategyBase

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

- (void)actionForBloom:(DCDewButton *)dew {
    do {
        ;
    } while (NO);
}

- (void)actionForDrop:(DCDewButton *)dew {
    do {
        ;
    } while (NO);
}

@end
