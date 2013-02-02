//
//  DCLocalImageLoader.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCLocalImageLoader.h"
#import "DCImageHelper.h"

NSString * const NOTIFY_LOCALIMAGELOADER_DOWNLOAD_DONE = @"NOTIFY_LOCALIMAGELOADER_DOWNLOAD_DONE";
NSString * const NOTIFY_LOCALIMAGELOADER_DOWNLOAD_ERROR = @"NOTIFY_LOCALIMAGELOADER_DOWNLOAD_ERROR";

@implementation DCLocalImageLoader

@synthesize uid = _uid;
@synthesize path = _path;
@synthesize cgImgRef = _cgImgRef;

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            ;
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (_cgImgRef) {
                CGImageRelease(_cgImgRef);
                _cgImgRef = nil;
            }
            
            SAFE_ARC_SAFERELEASE(_path);
            SAFE_ARC_SAFERELEASE(_uid);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)main {
    do {
        @synchronized(self) {
            if (self.revoke) {
                break;
            }
            
            if (!self.uid || !self.path) {
                break;
            }
            
            _cgImgRef = [DCImageHelper loadImageFromContentsOfFile:self.path withMaxPixelSize:0.0f];
            
            if (_cgImgRef) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCALIMAGELOADER_DOWNLOAD_DONE object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCALIMAGELOADER_DOWNLOAD_ERROR object:self];
            }
        }
    } while (NO);
}

@end
