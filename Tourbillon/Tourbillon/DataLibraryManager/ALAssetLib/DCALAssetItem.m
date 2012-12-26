//
//  DCALAssetItem.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetItem.h"
#import <ImageIO/ImageIO.h>

@implementation DCALAssetItem

@synthesize asset = _asset;

- (void)save:(NSString *)filePath {
    do {
        if (!filePath) {
            break;
        }
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
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
        dc_release(image);
    } while (NO);
}

- (id)initWithALAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

- (void)dealloc {
    do {
        self.asset = nil;
        dc_dealloc(super);
    } while (NO);
}

- (NSString *)uniqueID {
    NSString *result = nil;
    do {
        if (self.asset) {
            ALAssetRepresentation *representation = [self.asset defaultRepresentation];
            NSURL *url = [representation url];
            result = [url absoluteString];
        }
    } while (NO);
    return result;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
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
            dc_autorelease(result);
        } else if ([property isEqualToString:kDATAITEMPROPERTY_ORIGINIMAGE]) {
            result = [[UIImage alloc] initWithCGImage:[representation fullResolutionImage]];
            dc_autorelease(result);
        } else if ([property isEqualToString:kDATAITEMPROPERTY_FULLSCREENIMAGE]) {
            result = [[UIImage alloc] initWithCGImage:[representation fullScreenImage]];
            dc_autorelease(result);
        } else {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: unknown property"];
        }
    } while (NO);
    return result;
}

@end
