//
//  DCTimelineInterval.h
//  Whip
//
//  Created by Chen XiaoLiang on 13-2-19.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCTimelineInterval : NSObject {
}

@property (nonatomic, assign) NSInteger leftIndex;
@property (nonatomic, assign) NSInteger rightIndex;

@property (nonatomic, assign) CFGregorianUnits interval;

@end
