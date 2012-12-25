//
//  DCMediaDBOperator.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QUARTZ_DBFILE @"MediaDB.data"

@interface DCMediaDBOperator : NSObject {
}

@property (nonatomic, readonly) NSString *threadID;

+ (NSString *)archivePath;

- (id)initWithThreadID:(NSString *)threadID;

@end
