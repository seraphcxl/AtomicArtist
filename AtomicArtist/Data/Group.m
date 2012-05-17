//
//  Group.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "Group.h"
#import "Item.h"


@implementation Group

@dynamic inspectionRecord;
@dynamic posterItemUID;
@dynamic posterImage;
@dynamic posterImageData;
@dynamic uniqueID;
@dynamic items;

+ (CGSize)posterImageSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(POSTERIMAGE_SIZE_IPHONE, POSTERIMAGE_SIZE_IPHONE);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(POSTERIMAGE_SIZE_IPAD, POSTERIMAGE_SIZE_IPAD);
    } else {
        [NSException raise:@"Group error" format:@"Reason: Current device type unknown"];
        return CGSizeMake(0.0, 0.0);
    }
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    
    UIImage *posterImage = [UIImage imageWithData:self.posterImageData];
    [self setPrimitiveValue:posterImage forKey:@"posterImage"];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.inspectionRecord = [NSDate date];
}

#pragma mark CoreDataGeneratedAccessors
- (void)addAssets:(NSSet *)values {
    self.items = [self.items setByAddingObjectsFromSet:values];
}

- (void)addAssetsObject:(Item *)value {
    self.items = [self.items setByAddingObject:value];
}

- (void)removeAssets:(NSSet *)values {
    NSMutableSet *tmpSet = [[[NSMutableSet alloc] initWithSet:self.items] autorelease];
    
    for (Item *item in values) {
        [tmpSet removeObject:item];
    }
    
    self.items = [[tmpSet copy] autorelease];
}

- (void)removeAssetsObject:(Item *)value {
    NSMutableSet *tmpSet = [[[NSMutableSet alloc] initWithSet:self.items] autorelease];
    
    [tmpSet removeObject:value];
    
    self.items = [[tmpSet copy] autorelease];
}


@end
