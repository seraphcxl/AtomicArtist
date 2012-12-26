//
//  DCMediaDBManager.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"

@class DCMediaDBOperator;

@interface DCMediaDBManager : NSObject {
}


+ (DCMediaDBManager *)defaultManager;
+ (void)staticRelease;

- (DCMediaDBOperator *)queryMediaDBOperatorForThread:(NSThread *)aThread;
- (void)removeMediaDBOperatorForThread:(NSThread *)aThread;

@end
