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

@interface DCGroupViewController : UIViewController {
}

#pragma mark - DCGroupViewController - property - UI
@property (nonatomic, strong) DCGridView *gridView;

#pragma mark - DCGroupViewController - property - Data
@property (nonatomic, readonly) id<DCDataLibrary> dataLib;

@end
