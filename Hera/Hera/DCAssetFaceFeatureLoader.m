//
//  DCAssetFaceFeatureLoader.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-24.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCAssetFaceFeatureLoader.h"
#import "DCImageHelper.h"

@implementation DCAssetFaceFeatureLoader

@synthesize asset = _asset;

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_asset);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (CGImageSourceRef)getCGImageSource {
    return [DCImageHelper loadImageSourceFromALAsset:self.asset];
}

@end
