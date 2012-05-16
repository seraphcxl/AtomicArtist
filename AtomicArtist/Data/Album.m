//
//  Album.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/6/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "Album.h"
#import "Asset.h"


@implementation Album

@dynamic posterAssetURLString;
@dynamic posterImage;
@dynamic posterImageData;
@dynamic urlString;
@dynamic inspectionRecord;
@dynamic assets;

+ (CGSize)posterImageSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(POSTERIMAGE_SIZE_IPHONE, POSTERIMAGE_SIZE_IPHONE);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(POSTERIMAGE_SIZE_IPAD, POSTERIMAGE_SIZE_IPAD);
    } else {
        [NSException raise:@"Album error" format:@"Reason: Current device type unknown"];
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
    self.assets = [self.assets setByAddingObjectsFromSet:values];
}

- (void)addAssetsObject:(Asset *)value {
    self.assets = [self.assets setByAddingObject:value];
}

- (void)removeAssets:(NSSet *)values {
    NSMutableSet *tmpSet = [[[NSMutableSet alloc] initWithSet:self.assets] autorelease];
    
    for (Asset *asset in values) {
        [tmpSet removeObject:asset];
    }
    
    self.assets = [[tmpSet copy] autorelease];
}

- (void)removeAssetsObject:(Asset *)value {
    NSMutableSet *tmpSet = [[[NSMutableSet alloc] initWithSet:self.assets] autorelease];
    
    [tmpSet removeObject:value];
    
    self.assets = [[tmpSet copy] autorelease];
}
@end
