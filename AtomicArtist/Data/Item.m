//
//  Item.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "Group.h"


@implementation Item

@dynamic inspectionRecord;
@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic uniqueID;
@dynamic group;

+ (CGSize)thumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(THUMBNAIL_SIZE_IPHONE, THUMBNAIL_SIZE_IPHONE);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(THUMBNAIL_SIZE_IPAD, THUMBNAIL_SIZE_IPAD);
    } else {
        [NSException raise:@"Item error" format:@"Reason: Current device type unknown"];
        return CGSizeMake(0.0, 0.0);
    }
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    
    UIImage *thumbnail = [UIImage imageWithData:self.thumbnailData];
    [self setPrimitiveValue:thumbnail forKey:@"thumbnail"];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.inspectionRecord = [NSDate date];
}

@end
