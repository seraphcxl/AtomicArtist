//
//  DCFaceFeatureLoader.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-23.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCFaceFeatureLoader.h"
#import "DCFaceFeatureLoader_Inner.h"
#import <CoreImage/CoreImage.h>
#import "DCFaceFeature.h"
#import "DCImageHelper.h"
#import "DCMediaDBManager.h"
#import "DCMediaDBOperator.h"
#import "DCMediaDBCommonDefine.h"
#import "DCFaceFeatureHelper.h"

NSString * const NOTIFY_FACEFEATURELOADER_DONE = @"NOTIFY_FACEFEATURELOADER_DONE";

@interface DCFaceFeatureLoader () {
}

- (NSArray *)detectFaceFeatures;
- (void)saveFaceFeaturesToMediaDB:(NSArray *)faceFeatures;

@end

@implementation DCFaceFeatureLoader

@synthesize uid = _uid;
@synthesize pixelSize = _pixelSize;

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
            SAFE_ARC_SAFERELEASE(_uid);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (CGImageRef)getCGImage {
    return nil;
}

- (NSArray *)detectFaceFeatures {
    NSMutableArray *result = nil;
    CGImageSourceRef cgImgSrc = nil;
    CGImageRef cgImg = nil;
    do {
        cgImgSrc = [self getCGImageSource];
        
        if (!cgImgSrc) {
            break;
        }
        
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
        SAFE_ARC_AUTORELEASE(detectorOptions);
        CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        
        NSDictionary* metadata = (NSDictionary *)(__bridge NSString*)CGImageSourceCopyPropertiesAtIndex(cgImgSrc, 0, NULL);
        NSNumber *orientation = (NSNumber *)[metadata valueForKey:(NSString*)kCGImagePropertyOrientation];
        SAFE_ARC_AUTORELEASE(metadata);
        
        if (!orientation) {
            orientation = [NSNumber numberWithInt:[DCImageHelper UIImageOrientationToCGImagePropertyOrientation:UIImageOrientationUp]];
        }
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, (id)[NSNumber numberWithDouble:self.pixelSize], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
        cgImg = CGImageSourceCreateImageAtIndex(cgImgSrc, 0, (__bridge CFDictionaryRef)options);
        SAFE_ARC_AUTORELEASE(options);
        if (!cgImg) {
            break;
        }
        size_t cgImgWidth = CGImageGetWidth(cgImg);
        size_t cgImgHeight = CGImageGetHeight(cgImg);
        CIImage *ciImage = [CIImage imageWithCGImage:cgImg];
        NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];;
        NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
        
        if ([features count] > 0) {
            result = [NSMutableArray array];
            for (CIFaceFeature *ff in features) {
                CGRect faceRect = [ff bounds];
                DCFaceFeature *faceFeature = [[DCFaceFeature alloc] init];
                SAFE_ARC_AUTORELEASE(faceFeature);
                
                faceFeature.scaleTop = (cgImgHeight - faceRect.origin.y - faceRect.size.height) / cgImgHeight;
                faceFeature.scaleBottom = (cgImgHeight - faceRect.origin.y) / cgImgHeight;
                faceFeature.scaleLeft = faceRect.origin.x / cgImgWidth;
                faceFeature.scaleRight = (faceRect.origin.x + faceRect.size.width) / cgImgWidth;
                
                [result addObject:faceFeature];
            }
        }
    } while (NO);
    if (cgImg) {
        CGImageRelease(cgImg);
        cgImg = nil;
    }
    if (cgImgSrc) {
        CFRelease(cgImgSrc);
        cgImgSrc = nil;
    }
    return result;
}

- (void)saveFaceFeaturesToMediaDB:(NSArray *)faceFeatures {
    do {
        if (!faceFeatures) {
            break;
        }
        DCMediaDBOperator *mediaDBOperator = [[DCMediaDBManager sharedDCMediaDBManager] queryMediaDBOperatorForThread:[NSThread currentThread]];
        NSDictionary *args = [NSDictionary dictionaryWithObject:faceFeatures forKey:kITEM_FACEFEATUREARRAY];
        [mediaDBOperator updateItemWithUID:self.uid andArguments:args];
    } while (NO);
}

- (void)main {
    do {
        @synchronized(self) {
            if (self.revoke) {
                break;
            }
            
            NSArray *faceFeatures = [self detectFaceFeatures];
            
            if (!faceFeatures) {
                break;
            }
            
            if (self.revoke) {
                break;
            }
            
//            [self saveFaceFeaturesToMediaDB:faceFeatures];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            float top = -1.0;
            float bottom = -1.0;
            float left = -1.0;
            float right = -1.0;
            [DCFaceFeature calcBoundingRectangle:faceFeatures withTop:&top bottom:&bottom left:&left right:&right];
            [dict setObject:self.uid forKey:kFACEFEATURE_DATAITEM_UID];
            [dict setObject:[NSNumber numberWithFloat:top] forKey:kFACEFEATURE_RECT_TOP];
            [dict setObject:[NSNumber numberWithFloat:bottom] forKey:kFACEFEATURE_RECT_BOTTOM];
            [dict setObject:[NSNumber numberWithFloat:left] forKey:kFACEFEATURE_RECT_LEFT];
            [dict setObject:[NSNumber numberWithFloat:right] forKey:kFACEFEATURE_RECT_RIGHT];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_FACEFEATURELOADER_DONE object:dict];
        }
    } while (NO);
}

@end
