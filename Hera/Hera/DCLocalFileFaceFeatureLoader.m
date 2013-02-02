//
//  DCLocalFileFaceFeatureLoader.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-24.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCLocalFileFaceFeatureLoader.h"
#import "DCImageHelper.h"

@implementation DCLocalFileFaceFeatureLoader

@synthesize path = _path;

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_path);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (CGImageSourceRef)getCGImageSource {
    return [DCImageHelper loadImageSourceFromContentsOfFile:self.path];
}

@end
