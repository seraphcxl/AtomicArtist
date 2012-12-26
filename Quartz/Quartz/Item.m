//
//  Item.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-26.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "Item.h"
#import "Group.h"


#pragma mark - implementation Item
@implementation Item

@dynamic largeThumbnail;
@dynamic previewImage;
@dynamic recordTimestamp;
@dynamic smallThumbnail;
@dynamic uniqueID;
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
