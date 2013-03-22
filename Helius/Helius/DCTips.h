//
//  DCTips.h
//  Whip
//
//  Created by Chen XiaoLiang on 13-3-21.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

typedef enum {
    TPT_Center = 0,
    TPT_CustomLocation,
} TipsPopupType;

typedef enum {
    TPPO_Top = 0,
    TPO_Left,
    TPO_Bottom,
    TPO_Right,
} TipsPopupOrientation;

#define TIPS_DEF_WIDTH (48)
#define TIPS_DEF_HEIGHT (24)
#define TIPS_INNERSPACE (4)
#define TIPS_EDGE_WIDTH (8)
#define TIPS_EDGE_HEIGHT (8)
#define TIPS_TITLEFONTSIZE (18)
#define TIPS_DESCROPTIONFONTSIZE (16)
#define TIPS_TITLECOLOR ([UIColor whiteColor])
#define TIPS_DESCROPTIONCOLOR ([UIColor whiteColor])
#define TIPS_DURATION_SEC (5.f)
#define TIPS_DEFBACKGROUNDCOLOR ([UIColor colorWithRed:DC_RGB(0) green:DC_RGB(0) blue:DC_RGB(0) alpha:0.8f])

@class DCTips;

@protocol DCTipsActionDelegate <NSObject>

- (void)disdmissTips:(DCTips *)aTips;

@end

@interface DCTips : UIView

@property (nonatomic, assign) id<DCTipsActionDelegate> actionDelegate;
@property (nonatomic, assign) TipsPopupType type;

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *colorForTitle;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIFont *fontForTitle;

@property (nonatomic, copy) NSArray *descriptions;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *colorForDescription;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIFont *fontForDescription;

@property (nonatomic, assign) float duration;
@property (nonatomic, SAFE_ARC_PROP_STRONG) UIColor *backgroundColor;
@property (nonatomic, copy) NSString *backgroundImagePath;

@property (nonatomic, assign) CGPoint anchor;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) TipsPopupOrientation popupOrientation;

- (id)initWithType:(TipsPopupType)type titles:(NSArray *)titles andDescriptions:(NSArray *)descriptions;

@end
