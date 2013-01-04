//
//  UIGestureRecognizer+DCGridViewAdditions.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"


#pragma mark - interface UIGestureRecognizer (DCGridViewAdditions)
@interface UIGestureRecognizer (DCGridViewAdditions)

- (void)end;
- (BOOL)hasRecognizedValidGesture;

@end
