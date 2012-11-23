//
//  DCLoadPosterImageForALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadPosterImageForALAssetsGroup.h"
#import "DCImageHelper.h"
#import <ImageIO/ImageIO.h>

@interface DCLoadPosterImageForALAssetsGroup () {
}

+ (NSUInteger)calcPosterImageSize;

@end

@implementation DCLoadPosterImageForALAssetsGroup

@synthesize alAsset = _alAsset;

- (void)main {
    debug_NSLog(@"DCLoadPosterImageForALAssetsGroup main enter");
    CGImageSourceRef sourceRef = nil;
    NSData *data = nil;
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
        Byte *buffer = (Byte *)malloc(representation.size);
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        sourceRef = CGImageSourceCreateWithData((CFDataRef) data,  NULL);
        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)[NSNumber numberWithDouble:[DCLoadPosterImageForALAssetsGroup calcPosterImageSize] * 2], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
        CGImageRef thumbnailCGImage = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (CFDictionaryRef)options);
        debug_NSLog(@"image width = %zd %zd", CGImageGetWidth(thumbnailCGImage), CGImageGetHeight(thumbnailCGImage));
        if (CGImageGetWidth(thumbnailCGImage) == 0 || CGImageGetHeight(thumbnailCGImage) == 0) {
            UIImage *image = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
            if (_canceled) {
                break;
            }
            CGSize thumbnailSize;
            thumbnailSize.width = thumbnailSize.height = [DCLoadPosterImageForALAssetsGroup calcPosterImageSize];
            if (_canceled) {
                break;
            }
            self.thumbnail = [DCImageHelper image:image fillSize:thumbnailSize];
            if (_canceled) {
                break;
            }
        } else {
            self.thumbnail = [UIImage imageWithCGImage:thumbnailCGImage];
        }
        
        debug_NSLog(@"thumbnail size width = %f, height = %f", self.thumbnail.size.width, self.thumbnail.size.height);
        
        self.thumbnail = [DCImageHelper bezierImage:self.thumbnail withRadius:5.0 needCropSquare:YES];
        
        if (sourceRef) {
            CFRelease(sourceRef);
        }
        if (_canceled) {
            break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_POSTERIMAGELOADED object:self];
        _finished = YES;
    } while (NO);
    debug_NSLog(@"DCLoadPosterImageForALAssetsGroup main exit");
}

+ (NSUInteger)calcPosterImageSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return POSTERIMAGE_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return POSTERIMAGE_SIZE_IPAD;
    } else {
        [NSException raise:@"DCLoadPosterImageForALAssetsGroup error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (id)initWithItemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID andALAsset:(ALAsset *)alAsset {
    self = [super initWithItemUID:itemUID dataGroupUID:dataGroupUID];
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
