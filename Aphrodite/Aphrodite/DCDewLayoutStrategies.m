//
//  DCDewLayoutStrategies.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCDewLayoutStrategies.h"

@interface DCDewLayoutStrategyFactory () {
}

@end

@implementation DCDewLayoutStrategyFactory

+ (id<DCDewLayoutStrategy>)strategyFromType:(DCDewLayoutStrategyType)type {
    id<DCDewLayoutStrategy> result = nil;
    do {
        @synchronized(self) {
        }
    } while (NO);
    return result;
}

@end

@interface DCDewLayoutStrategyBase () {
}

@end

@implementation DCDewLayoutStrategyBase

@synthesize rotate = _rotate;
@synthesize animationDuration = _animationDuration;

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _rotate = NO;
            _animationDuration = 0.0f;
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            _rotate = NO;
            _animationDuration = 0.0f;
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)layout:(DCDewButton *)dew withAngle:(CGFloat)angle {
    do {
        ;
    } while (NO);
}

@end


