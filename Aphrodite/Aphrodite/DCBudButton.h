//
//  DCBudButton.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@class DCBudButton;

@protocol DCBudButtonActionDelegate <NSObject>

- (void)DCBudButton:(DCBudButton *)budbutton bloom:(BOOL)bloomy;

@end

@interface DCBudButton : UIButton {
}

@property (nonatomic, SAFE_ARC_PROP_WEAK) id<DCBudButtonActionDelegate> actionDelegate;

@property (atomic, readonly, getter = isBloomy) BOOL bloomy;

- (id)initWithFrame:(CGRect)frame andBloomyState:(BOOL) bloomy;

@end
