//
//  DCMediaDBManager.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "DCSingletonTemplate.h"
#import "SafeARC.h"

@class DCMediaDBOperator;

@interface DCMediaDBManager : NSObject {
}


DEFINE_SINGLETON_FOR_HEADER(DCMediaDBManager);

- (DCMediaDBOperator *)queryMediaDBOperatorForThread:(NSThread *)aThread;
- (void)removeMediaDBOperatorForThread:(NSThread *)aThread;

@end
