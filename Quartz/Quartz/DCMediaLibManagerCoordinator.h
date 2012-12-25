//
//  DCMediaLibManagerCoordinator.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCMediaLibManager;

@interface DCMediaLibManagerCoordinator : NSObject {
}

+ (DCMediaLibManagerCoordinator *)defaultCoordinator;
+ (void)staticRelease;

- (DCMediaLibManager *)queryMediaLibManagerForThread:(NSThread *)aThread;

@end
