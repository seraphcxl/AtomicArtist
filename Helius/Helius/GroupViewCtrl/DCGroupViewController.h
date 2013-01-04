//
//  DCGroupViewController.h
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12/31/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeARC.h"
#import "DCCommonConstants.h"
#import "DCGridView.h"
#import "DCUniformDataProtocol.h"

@class DCALAssetsGroupView;

@interface DCGroupViewController : UIViewController {
}

#pragma mark - DCGroupViewController - property - UI
@property (nonatomic, SAFE_ARC_PROP_STRONG) DCGridView *gridView;

#pragma mark - DCGroupViewController - property - Data
@property (nonatomic, SAFE_ARC_PROP_STRONG) id<DCDataLibrary> dataLib;

@end
