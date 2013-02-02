//
//  DCMediaPocketDataItem.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCMediaPocketDataProtocel.h"

@interface DCMediaPocketDataItem : NSObject <DCMediaPocketDataItemProtocol> {
}

- (id)initWithDataItem:(id<DCDataItem>) dataItem andUseCount:(NSUInteger) useCount;

@end
