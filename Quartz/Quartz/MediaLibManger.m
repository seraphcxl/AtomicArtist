//
//  MediaLibManger.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-25.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "MediaLibManger.h"


#pragma mark - interface MediaLibManger
@interface MediaLibManger () {
}

@end


#pragma mark - implementation MediaLibManger
@implementation MediaLibManger

@synthesize threadID = _threadID;

#pragma mark - MediaLibManger - Public method
+ (NSString *)archivePath {
    NSString *result = nil;
    do {
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        // Get one and only document directory from that list
        NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        
        result = [documentDirectory stringByAppendingPathComponent:@"MediaLib.data"];
    } while (NO);
    return result;
}

- (id)initWithThreadID:(NSString *)threadID {
    id result = nil;
    do {
        if (!threadID) {
            break;
        }
        self = [super init];
        if (self) {
            _threadID = [threadID copy];
        }
        result = self;
    } while (NO);
    return result;
}

#pragma mark - MediaLibManger - Private method

@end
