//
//  DCMediaBucket.h
//
//
//  Created by Chen XiaoLiang on 13-2-19.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCMediaBucket : NSObject

- (NSUInteger)itemCount;
- (NSString *)itemUIDAtIndex:(NSUInteger)idx;
- (void)insertItemUID:(NSString *)itemUID;
- (void)removeItemUID:(NSString *)itemUID;
- (NSInteger)findItem:(NSString *)uniqueID;

@end
