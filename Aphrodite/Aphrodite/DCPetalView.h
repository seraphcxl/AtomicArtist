//
//  DCPetalView.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@class DCDewButton;

@interface DCPetalView : UIView {
}

@property (nonatomic, assign) CGFloat angle;

+ (NSString *)uniqueIDForAngle:(CGFloat)angle;
- (NSString *)uniqueID;

// Dew
- (DCDewButton *)getDew:(CGFloat)radius;

- (void)addDew:(DCDewButton *)aDewButton;

@end
