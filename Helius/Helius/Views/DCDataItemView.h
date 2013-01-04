//
//  DCDataItemView.h
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12/31/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeARC.h"
#import "DCCommonConstants.h"
#import "DCUniformDataProtocol.h"

@interface DCDataItemView : UIView {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG) id<DCDataItem> dataItem;

@end
