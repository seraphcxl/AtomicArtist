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
#import <ImageIO/ImageIO.h>

@interface DCLoadThumbnailForALAssetItem () {
}

+ (NSUInteger)calcThumbnailSize;

@end

@implementation DCLoadThumbnailForALAssetItem

@synthesize alAsset = _alAsset;

- (void)main {
    NSLog(@"DCLoadThumbnailForALAssetItem main enter");
    do {
        if (_canceled) {
            break;
        }
        if (!self.alAsset) {
            break;
        }
        ALAssetRepresentation *representation = [self.alAsset defaultRepresentation];
        if (!representation) {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: representation == nil"];
            break;
        }
        if (_canceled) {
            break;
        }
        UIImage *tmpImage = nil;
        NSLog(@"test//////////////////////////////////////000");
        UIImage *image = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
        if (_canceled) {
            break;
        }
        CGSize thumbnailSize;
        thumbnailSize.width = thumbnailSize.height = [DCLoadThumbnailForALAssetItem calcThumbnailSize];
        if (_canceled) {
            break;
        }
        tmpImage = [DCImageHelper image:image fillSize:thumbnailSize];
        if (_canceled) {
            break;
        }
        NSLog(@"test//////////////////////////////////////001");
//        Byte *buffer = (Byte *)malloc(representation.size);
//        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
//        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:NO];
//        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef) data,  NULL);
//        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)[NSNumber numberWithDouble:[DCLoadThumbnailForALAssetItem calcThumbnailSize]], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
//        CGImageRef thumbnailCGImage = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (CFDictionaryRef)options);
//        tmpImage = [UIImage imageWithCGImage:thumbnailCGImage];
        NSLog(@"test//////////////////////////////////////002");
        self.thumbnail = [DCImageHelper bezierImage:tmpImage withRadius:5.0 needCropSquare:YES];
        NSLog(@"thumbnail size width = %f, height = %f", self.thumbnail.size.width, self.thumbnail.size.height);
        if (_canceled) {
            break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_THUMBNAILLOADED object:self];
        _finished = YES;
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
