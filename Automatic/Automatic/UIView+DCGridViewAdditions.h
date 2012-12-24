//
//  UIView+DCGridViewAdditions.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"


#pragma mark - interface UIView (DCGridViewAdditions)
@interface UIView (DCGridViewAdditions)

- (void)shakeStatus:(BOOL)enabled;
- (void)recursiveEnumerateSubviewsUsingBlock:(void (^)(UIView *view, BOOL *stop))block;

@end
