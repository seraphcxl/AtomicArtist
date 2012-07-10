//
//  DCBrower.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGroupViewController.h"
#import "DCBrowerViewController.h"

@interface DCBrower : NSObject <UINavigationControllerDelegate>

@property (readonly, nonatomic) DCBrowerViewController *naviCtrl;
@property (readonly, nonatomic) enum GROUPVIEWCTRL_TYPE type;

- (id)init:(enum GROUPVIEWCTRL_TYPE)type;

@end
