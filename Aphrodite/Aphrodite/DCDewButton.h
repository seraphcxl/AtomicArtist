//
//  DCDewButton.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-2-4.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCDewButton : UIButton {
}

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, readonly) CGPoint anchor;

+ (NSString *)uniqueIDForRadius:(CGFloat)radius;
- (NSString *)uniqueID;

@end
