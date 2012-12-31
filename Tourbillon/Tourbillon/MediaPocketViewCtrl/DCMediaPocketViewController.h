//
//  DCMediaPocketViewController.h
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

@interface DCMediaPocketViewController : UIViewController {
}

#pragma mark - DCMediaPocketViewController - property - UI
@property (nonatomic, SAFE_ARC_PROP_STRONG) DCGridView *gridView;

#pragma mark - DCMediaPocketViewController - property - Data
@property (nonatomic, readonly) NSMutableArray *dataArray;

@end
