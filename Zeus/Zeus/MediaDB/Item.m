//
//  Item.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-23.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "Item.h"
#import "Group.h"
#import "DCCommonConstants.h"
#import "SafeARC.h"

@implementation Item

@dynamic faceFeatureData;
@dynamic faceFeatureArray;
@dynamic largeThumbnail;
@dynamic md5;
@dynamic previewImage;
@dynamic recordTimestamp;
@dynamic smallThumbnail;
@dynamic uniqueID;
@dynamic group;

- (void)awakeFromFetch {
    do {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.faceFeatureData];
        SAFE_ARC_AUTORELEASE(unarchiver);
        self.faceFeatureArray = [unarchiver decodeObjectForKey:@"faceFeatureArray"];
        [unarchiver finishDecoding];
        
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
