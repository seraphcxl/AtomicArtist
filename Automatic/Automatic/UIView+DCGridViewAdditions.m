//
//  UIView+DCGridViewAdditions.m
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "UIView+DCGridViewAdditions.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark - implementation UIView (DCGridViewAdditions)
@implementation UIView (DCGridViewAdditions)

- (void)shakeStatus:(BOOL)enabled {
    do {
        if (enabled) {
            CGFloat rotation = 0.03;
            
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
            shake.duration = 0.13;
            shake.autoreverses = YES;
            shake.repeatCount  = MAXFLOAT;
            shake.removedOnCompletion = NO;
            shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -rotation, 0.0 ,0.0 ,1.0)];
            shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
            
            [self.layer addAnimation:shake forKey:@"shakeAnimation"];
        } else {
            [self.layer removeAnimationForKey:@"shakeAnimation"];
        }
    } while (NO);
}

- (void)recursiveEnumerateSubviewsUsingBlock:(void (^)(UIView *view, BOOL *stop))block {
    do {
        if (self.subviews.count == 0) {
            return;
        }
        
        for (UIView *subview in [self subviews]) {
            BOOL stop = NO;
            block(subview, &stop);
            if (stop) {
                return;
            }
            [subview recursiveEnumerateSubviewsUsingBlock:block];
        }
    } while (NO);
}


@end
