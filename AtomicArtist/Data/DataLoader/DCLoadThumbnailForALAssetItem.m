//
//  DCLoadThumbnailForALAssetItem.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadThumbnailForALAssetItem.h"
#import "DCImageHelper.h"
#import "DCDataLoader.h"

@interface DCLoadThumbnailForALAssetItem () {
}

+ (NSUInteger)calcThumbnailSize;

@end

@implementation DCLoadThumbnailForALAssetItem

@synthesize alAsset = _alAsset;

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
        UIImage *image = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
//        CGSize tmpSize = image.size;
        CGSize thumbnailSize;
        thumbnailSize.width = thumbnailSize.height = [DCLoadThumbnailForALAssetItem calcThumbnailSize];
        self.thumbnail = [DCImageHelper image:image fitInSize:thumbnailSize];
//        CGSize tmpSize1 = self.thumbnail.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_THUMBNAILLOADED object:self];
    } while (NO);
    NSLog(@"DCLoadThumbnailForALAssetItem main exit");
}

+ (NSUInteger)calcThumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return THUMBNAIL_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return THUMBNAIL_SIZE_IPAD;
    } else {
        [NSException raise:@"DCLoadThumbnailForALAssetItem error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (id)initWithItemUID:(NSString *)itemUID andALAsset:(ALAsset *)alAsset {
    self = [super initWithItemUID:itemUID];
    if (self) {
        _alAsset = alAsset;
        [_alAsset retain];
    }
    return self;
}

- (void)dealloc {
    if (_alAsset) {
        [_alAsset release];
        _alAsset = nil;
    }
    
    [super dealloc];
}

@end
