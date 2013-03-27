//
//  DCSpotlight.m
//  Helius
//
//  Created by Chen XiaoLiang on 13-3-27.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCSpotlight.h"

@interface DCSpotlight () {
}

@end

@implementation DCSpotlight

@synthesize animationDuration = _animationDuration;
@synthesize gradientColor = _gradientColor;
@synthesize spotlightGradientRef = _spotlightGradientRef;

- (id)initWithGradientColor:(UIColor *)aGradientColor {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _gradientColor = aGradientColor;
            SAFE_ARC_RETAIN(_gradientColor);
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f};
            [self.gradientColor getRed:&colors[4] green:&colors[5] blue:&colors[6] alpha:&colors[7]];
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            _spotlightGradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGGradientRetain(_spotlightGradientRef);
            CGColorSpaceRelease(colorSpace);
        }
        return self;
    }
}

- (void)dealloc {
    @synchronized(self) {
        do {
            CGGradientRelease(_spotlightGradientRef);
            _spotlightGradientRef = nil;
            
            SAFE_ARC_SAFERELEASE(_gradientColor);
            
            SAFE_ARC_SUPER_DEALLOC();
        } while (NO);
    }
}

@end


@interface DCRadialSpotlight () {
}

@end

@implementation DCRadialSpotlight

@synthesize centerAnchor = _centerAnchor;
@synthesize spotlightRadius = _spotlightRadius;
@synthesize gradientRadius = _gradientRadius;

- (void)dealloc {
    @synchronized(self) {
        do {
            SAFE_ARC_SUPER_DEALLOC();
        } while (NO);
    }
}

@end


@interface DCRectSpotlight () {
}

@end

@implementation DCRectSpotlight

@synthesize rectangle = _rectangle;

- (void)dealloc {
    @synchronized(self) {
        do {
            SAFE_ARC_SUPER_DEALLOC();
        } while (NO);
    }
}

@end
