//
//  DCLoadPosterImageForALAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadPosterImageForALAssetsGroup.h"
#import "DCImageHelper.h"

@interface DCLoadPosterImageForALAssetsGroup () {
}

+ (NSUInteger)calcPosterImageSize;

@end

@implementation DCLoadPosterImageForALAssetsGroup

@synthesize alAsset = _alAsset;

- (void)main {
    NSLog(@"DCLoadPosterImageForALAssetsGroup main enter");
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
        thumbnailSize.width = thumbnailSize.height = [DCLoadPosterImageForALAssetsGroup calcPosterImageSize];
        UIImage *tmpImage = [DCImageHelper image:image fillSize:thumbnailSize];
        self.thumbnail = [DCImageHelper bezierImage:tmpImage withRadius:5.0 needCropSquare:YES];
//        CGSize tmpSize1 = self.thumbnail.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_POSTERIMAGELOADEDFORALASSETSGROUP object:self];
    } while (NO);
    NSLog(@"DCLoadPosterImageForALAssetsGroup main exit");
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
        self.alAsset = alAsset;
    }
    return self;
}

- (void)dealloc {
    self.alAsset = nil;
    
    [super dealloc];
}

@end
