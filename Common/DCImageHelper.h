//
//  DCImageHelper.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

#define ALASSETLIB_AVAILABLE 1

#ifdef ALASSETLIB_AVAILABLE
#import <AssetsLibrary/AssetsLibrary.h>
#endif


@interface DCImageHelper : NSObject

#pragma mark - Fitting
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGSize)fitoutSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize;

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)size;
+ (UIImage *)image:(UIImage *)image fillSize:(CGSize)size;
+ (UIImage *)image:(UIImage *)image centerInSize:(CGSize)size;

#pragma mark - Rotate
+ (CGFloat)degreesToRadians:(CGFloat)degrees;
+ (UIImage *)image:(UIImage *)image rotatedByDegrees:(CGFloat)degrees;
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;
+ (UIImage *)doUnrotateImage:(UIImage *)image fromOrientation:(UIImageOrientation)orient;

#pragma mark - Reflection
+ (void)addSimpleReflectionToView:(UIView *)view;
+ (void)addReflectionToView:(UIView *)view;
+ (UIImage *)reflectionOfView:(UIView *)view withPercent:(CGFloat)percent;
+ (CGImageRef)createGradientImage:(CGSize)size;
+ (UIImage *)bezierImage:(UIImage *)image withRadius:(CGFloat)radius needCropSquare:(BOOL)needCropSquare;

#pragma mark - Load image
#ifdef ALASSETLIB_AVAILABLE
typedef enum {
    DCImageShapeType_Original = 0,
    DCImageShapeType_Square,
} DCImageShapeType;

+ (UIImage *)loadImageFromALAsset:(ALAsset *)asset withShape:(DCImageShapeType)type andMaxPixelSize:(CGFloat)pixelSize;

+ (CGImageRef)loadImageFromALAsset:(ALAsset *)asset withMaxPixelSize:(CGFloat)pixelSize;

+ (CGImageSourceRef)loadImageSourceFromALAsset:(ALAsset *)asset;
#endif

+ (NSInteger)UIImageOrientationToCGImagePropertyOrientation:(UIImageOrientation) imageOrientation;

+ (CGImageRef)loadImageFromContentsOfFile:(NSString *)path withMaxPixelSize:(CGFloat)pixelSize;

+ (CGImageSourceRef)loadImageSourceFromContentsOfFile:(NSString *)path;
@end
