//
//  Item.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-25.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "Item.h"
#import "Group.h"


#pragma mark - implementation Item
@implementation Item

@dynamic uniqueID;
@dynamic recordTimestamp;
@dynamic smallThumbnail;
@dynamic largeThumbnail;
@dynamic group;

- (void)awakeFromFetch {
    do {
        [super awakeFromFetch];
    } while (NO);
}

- (void)awakeFromInsert {
    do {
        [super awakeFromInsert];
        
        self.recordTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    } while (NO);
}

@end
