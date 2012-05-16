//
//  Asset.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/6/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "Asset.h"
#import "Album.h"


@implementation Asset

@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic urlString;
@dynamic inspectionRecord;
@dynamic album;

+ (CGSize)thumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(THUMBNAIL_SIZE_IPHONE, THUMBNAIL_SIZE_IPHONE);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(THUMBNAIL_SIZE_IPAD, THUMBNAIL_SIZE_IPAD);
    } else {
        [NSException raise:@"Asset error" format:@"Reason: Current device type unknown"];
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
