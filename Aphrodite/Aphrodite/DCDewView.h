//
//  DCDewView.h
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCDewView : UIView {
}

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, readonly) CGPoint anchor;

- (NSString *)uniqueID;

@end
