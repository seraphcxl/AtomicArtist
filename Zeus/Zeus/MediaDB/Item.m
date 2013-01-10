//
//  Item.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-10.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "Item.h"
#import "Group.h"


@implementation Item

@dynamic largeThumbnail;
@dynamic previewImage;
@dynamic recordTimestamp;
@dynamic smallThumbnail;
@dynamic uniqueID;
@dynamic md5;
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
