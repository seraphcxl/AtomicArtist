//
//  DCTipsView.h
//  Whip
//
//  Created by Chen XiaoLiang on 13-3-21.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@class DCTipsView;

@protocol DCTipsViewActionDelegate <NSObject>

- (void)disdmissTipsView:(DCTipsView *)aTipsView;

@end

@interface DCTipsView : UIView

@property (nonatomic, assign) id<DCTipsViewActionDelegate> actionDelegate;
@property (nonatomic, copy) NSArray *tipsArray;

@end
