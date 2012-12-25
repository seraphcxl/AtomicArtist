//
//  MediaLibManger.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-25.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaLibManger : NSObject {
}

@property (nonatomic, readonly) NSString *threadID;

+ (NSString *)archivePath;

- (id)initWithThreadID:(NSString *)threadID;

@end
