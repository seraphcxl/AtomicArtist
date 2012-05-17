//
//  DCALAssetItem.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetItem.h"

@implementation DCALAssetItem

@synthesize alAsset = _alAsset;

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

- (id)valueForProperty:(DATAITEMPROPERTY)property {
    if (!self.alAsset) {
        [NSException raise:@"DCALAssetItem error" format:@"Reason: self.alAsset == nil"];
    }
    ALAssetRepresentation *representation = [self.alAsset defaultRepresentation];
    switch (property) {
        case DATAITEMPROPERTY_UID: {
            NSURL *url = [representation url];
            return [url absoluteString];
        }
            break;
        case DATAITEMPROPERTY_FILENAME: {
            return [representation filename];
        }
            break;
        case DATAITEMPROPERTY_URL: {
            return [representation url];
        }
            break;
        case DATAITEMPROPERTY_TYPE: {
            return [self.alAsset valueForProperty:ALAssetPropertyType];
        }
            break;
        case DATAITEMPROPERTY_DATE: {
            return [self.alAsset valueForProperty:ALAssetPropertyDate];
        }
            break;
        case DATAITEMPROPERTY_ORIENTATION: {
            return [self.alAsset valueForProperty:ALAssetPropertyOrientation];
        }
            break;
        case DATAITEMPROPERTY_THUMBNAIL: {
            UIImage *thumbnail = [[[UIImage alloc] initWithCGImage:[self.alAsset thumbnail]] autorelease];
            return thumbnail;
        }
            break;
        case DATAITEMPROPERTY_ORIGINIMAGE: {
            UIImage *originImage = [[[UIImage alloc] initWithCGImage:[representation fullResolutionImage]] autorelease];
            return originImage;
        }
            break;
        case DATAITEMPROPERTY_FULLSCREENIMAGE: {
            UIImage *fullScreenImage = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
            return fullScreenImage;
        }
            break;
            
        default: {
            [NSException raise:@"DCALAssetItem error" format:@"Reason: property error"];
            return nil;
        }
            break;
    }
}

@end
