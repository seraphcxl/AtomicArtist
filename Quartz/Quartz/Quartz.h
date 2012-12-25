//
//  Quartz.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-4.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaLibManger;

@interface Quartz : NSObject {
}

+ (Quartz *)defaultQuartz;
+ (void)staticRelease;

- (MediaLibManger *)queryMediaLibMangerForThread:(NSThread *)aThread;

@end