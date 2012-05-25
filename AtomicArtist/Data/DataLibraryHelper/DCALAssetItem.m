//
//  DCALAssetItem.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetItem.h"
#import <ImageIO/ImageIO.h>
#import "DCLoadThumbnailForALAssetItem.h"

@implementation DCALAssetItem

@synthesize alAsset = _alAsset;

- (NSOperation *)createOperationForLoadCacheThumbnail {
    NSOperation *result = nil;
    do {
        if (self.alAsset) {
            result = [[[DCLoadThumbnailForALAssetItem alloc] initWithItemUID:[self uniqueID] andALAsset:self.alAsset] autorelease];
        }
    } while (NO);
    return result;
}

- (void)dealloc {
    self.alAsset = nil;
    
    [super dealloc];
}

- (NSString *)uniqueID {
    if (self.alAsset) {
        ALAssetRepresentation *representation = [self.alAsset defaultRepresentation];
        NSURL *url = [representation url];
        return [url absoluteString];
    } else {
        return nil;
    }
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    id result = nil;
    do {
        if (!self.alAsset) {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: self.alAsset == nil"];
            break;
        }
        ALAssetRepresentation *representation = [self.alAsset defaultRepresentation];
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
            result = [self.alAsset valueForProperty:ALAssetPropertyType];
        } else if ([property isEqualToString:kDATAITEMPROPERTY_DATE]) {
            result = [self.alAsset valueForProperty:ALAssetPropertyDate];
        } else if ([property isEqualToString:kDATAITEMPROPERTY_ORIENTATION]) {
            result = [self.alAsset valueForProperty:ALAssetPropertyOrientation];
        } else if ([property isEqualToString:kDATAITEMPROPERTY_THUMBNAIL]) {
            result = [[[UIImage alloc] initWithCGImage:[self.alAsset thumbnail]] autorelease];
        } else if ([property isEqualToString:kDATAITEMPROPERTY_ORIGINIMAGE]) {
            result = [[[UIImage alloc] initWithCGImage:[representation fullResolutionImage]] autorelease];
        } else if ([property isEqualToString:kDATAITEMPROPERTY_FULLSCREENIMAGE]) {
            result = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
        } else {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: unknown property"];
        }
    } while (NO);
    return result;
}

@end
