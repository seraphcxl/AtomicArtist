//
//  DCLoadThumbnailForALAssetItem.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadThumbnailForALAssetItem.h"
#import "DCImageHelper.h"

@interface DCLoadThumbnailForALAssetItem () {
}

- (NSUInteger)calcThumbnailSize;

@end

@implementation DCLoadThumbnailForALAssetItem

@synthesize alAsset = _alAsset;
@synthesize thumbnail = _thumbnail;

- (void)main {
    NSLog(@"DCLoadThumbnailForALAssetItem main enter");
    do {
        if (!self.alAsset) {
            break;
        }
        ALAssetRepresentation *representation = [self.alAsset defaultRepresentation];
        if (!representation) {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: representation == nil"];
            break;
        }
        UIImage *image = [[[UIImage alloc] initWithCGImage:[representation fullResolutionImage]] autorelease];
        CGSize thumbnailSize;
        thumbnailSize.width = thumbnailSize.height = [self calcThumbnailSize];
        self.thumbnail = [DCImageHelper image:image fitInSize:thumbnailSize];
        CGSize tmpSize = self.thumbnail.size;
        int i = 0;
    } while (NO);
    NSLog(@"DCLoadThumbnailForALAssetItem main exit");
}

- (NSUInteger)calcThumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return THUMBNAIL_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return THUMBNAIL_SIZE_IPAD;
    } else {
        [NSException raise:@"DCLoadThumbnailForALAssetItem error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (id)initWithALAsset:(ALAsset *)alAsset{
    self = [super init];
    if (self) {
        self.alAsset = alAsset;
    }
    return self;
}

- (void)dealloc {
    self.alAsset = nil;
    self.thumbnail = nil;
    [super dealloc];
}

@end
