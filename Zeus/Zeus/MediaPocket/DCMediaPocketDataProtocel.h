//
//  DCMediaPocketDataProtocel.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCUniformDataProtocol.h"

@protocol DCMediaPocketDataItemProtocol <DCDataItem>

- (NSUInteger)increaseUseCount;
- (NSUInteger)decreaseUseCount;
- (NSUInteger)useCount;
- (void)zeroUseCount;

- (NSURL *)URL;

@end

