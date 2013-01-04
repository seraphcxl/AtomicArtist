//
//  UIGestureRecognizer+DCGridViewAdditions.m
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "UIGestureRecognizer+DCGridViewAdditions.h"


#pragma mark - implementation UIGestureRecognizer (DCGridViewAdditions)
@implementation UIGestureRecognizer (DCGridViewAdditions)

- (void)end {
    do {
        BOOL currentStatus = self.enabled;
        self.enabled = NO;
        self.enabled = currentStatus;
    } while (NO);
}

- (BOOL)hasRecognizedValidGesture {
    return (self.state == UIGestureRecognizerStateChanged || self.state == UIGestureRecognizerStateBegan);
}

@end
