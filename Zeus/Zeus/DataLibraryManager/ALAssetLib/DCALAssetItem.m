//
//  DCALAssetItem.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetItem.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@implementation DCALAssetItem

@synthesize actionDelegate = _actionDelegate;
@synthesize asset = _asset;

- (DataSourceType)type {
    return DataSourceType_AssetsLib;
}

- (void)save:(NSString *)filePath {
    UIImage *image = nil;
    do {
        if (!filePath) {
            break;
        }
        
        @synchronized(self) {
            ALAssetRepresentation *rep = [self.asset defaultRepresentation];
            image = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
        }
        
        if (image) {
            CGSize size = [image size];
            dc_debug_NSLog(@"Full screen image: %f * %f", size.width, size.height);
            NSData *data = nil;
            if ([filePath hasSuffix:@".png"]) {
                data = UIImagePNGRepresentation(image);
            } else if ([filePath hasSuffix:@".jpg"] || [filePath hasSuffix:@".jpeg"]) {
                data = UIImageJPEGRepresentation(image, 1);
            }
            if (data) {
                [data writeToFile:filePath atomically:YES];
            }
            
            [self.actionDelegate notifyFileSaved:self to:filePath];
        }
    } while (NO);
    SAFE_ARC_SAFERELEASE(image);
}

- (id)initWithALAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        @synchronized(self) {
            self.asset = asset;
        }
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            self.asset = nil;
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        @synchronized(self) {
            if (self.asset) {
                ALAssetRepresentation *representation = [self.asset defaultRepresentation];
                NSURL *url = [representation url];
                result = [url absoluteString];
            }
        }
    } while (NO);
    return result;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        @synchronized(self) {
            if (!self.asset) {
                [NSException raise:@"DCALAssetItem error" format:@"Reason: self.asset == nil"];
                break;
            }
            ALAssetRepresentation *representation = [self.asset defaultRepresentation];
            if (!representation) {
                [NSException raise:@"DCALAssetItem error" format:@"Reason: representation == nil"];
                break;
            }
            if ([property isEqualToString:kDATAITEMPROPERTY_UID]) {
                NSURL *url = [representation url];
                result = [url absoluteString];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_FILENAME]) {
                result = [representation filename];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_URL]) {
                result = [representation url];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_TYPE]) {
                result = [self.asset valueForProperty:ALAssetPropertyType];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_DATE]) {
                result = [self.asset valueForProperty:ALAssetPropertyDate];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_ORIENTATION]) {
                result = [self.asset valueForProperty:ALAssetPropertyOrientation];
            } else if ([property isEqualToString:kDATAITEMPROPERTY_THUMBNAIL]) {
                result = [[UIImage alloc] initWithCGImage:[self.asset thumbnail]];
                SAFE_ARC_AUTORELEASE(result);
            } else if ([property isEqualToString:kDATAITEMPROPERTY_ORIGINIMAGE]) {
                result = [[UIImage alloc] initWithCGImage:[representation fullResolutionImage]];
                SAFE_ARC_AUTORELEASE(result);
            } else if ([property isEqualToString:kDATAITEMPROPERTY_FULLSCREENIMAGE]) {
                result = [[UIImage alloc] initWithCGImage:[representation fullScreenImage]];
                SAFE_ARC_AUTORELEASE(result);
            } else {
                [NSException raise:@"DCALAssetItem error" format:@"Reason: unknown property"];
            }
        }
    } while (NO);
    return result;
}

@end
