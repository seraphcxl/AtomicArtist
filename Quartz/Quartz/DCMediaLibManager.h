//
//  DCMediaLibManager.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMediaLibManager : NSObject {
}

@property (nonatomic, readonly) NSString *threadID;

+ (NSString *)archivePath;

- (id)initWithThreadID:(NSString *)threadID;

@end
