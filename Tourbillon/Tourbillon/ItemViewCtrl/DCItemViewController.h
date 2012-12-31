//
//  DCItemViewController.h
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

@class DCALAssetItemView;

@interface DCItemViewController : UIViewController {
}

#pragma mark - DCItemViewController - property - UI
@property (nonatomic, SAFE_ARC_PROP_STRONG) DCGridView *gridView;

#pragma mark - DCItemViewController - property - Data
@property (nonatomic, SAFE_ARC_PROP_STRONG) id<DCDataGroup> dataGroup;

@end
