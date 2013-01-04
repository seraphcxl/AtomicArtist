//
//  DCMediaDBOperator.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

#define QUARTZ_DBFILE @"MediaDB.data"

@class Item;
@class Group;

@interface DCMediaDBOperator : NSObject {
}

@property (nonatomic, readonly) NSString *threadID;
@property (nonatomic, SAFE_ARC_PROP_WEAK, readonly) NSThread *thread;

+ (NSString *)archivePath;

- (id)initWithThread:(NSThread *)thread andThreadID:(NSString *)threadID;

#pragma mark - DCMediaDBOperator - Item
- (Item *)getItemWithUID:(NSString *)itemUID;
- (void)createItemWithUID:(NSString *)itemUID andArguments:(NSDictionary *)args;

#pragma mark - DCMediaDBOperator - Group
- (Group *)getGroupWithUID:(NSString *)groupUID;
- (void)createGroupWithUID:(NSString *)groupUID andArguments:(NSDictionary *)args;
- (void)updateGroupWithUID:(NSString *)groupUID andArguments:(NSDictionary *)args;

@end
