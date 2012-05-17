//
//  DCImageHelper.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCImageHelper : NSObject

#pragma mark fitting
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGSize)fitoutSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize;

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)size;
+ (UIImage *)image:(UIImage *)image fillSize:(CGSize)size;
+ (UIImage *)image:(UIImage *)image centerInSize:(CGSize)size;

#pragma mark rotate
+ (CGFloat)degreesToRadians:(CGFloat)degrees;
+ (UIImage *)image:(UIImage *)image rotatedByDegrees:(CGFloat)degrees;
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;
+ (UIImage *)doUnrotateImage:(UIImage *)image fromOrientation:(UIImageOrientation)orient;

#pragma mark reflection
+ (void)addSimpleReflectionToView:(UIView *)view;
+ (void)addReflectionToView:(UIView *)view;
+ (UIImage *)reflectionOfView:(UIView *)view withPercent:(CGFloat)percent;
+ (CGImageRef)createGradientImage:(CGSize)size;
+ (UIImage *)bezierImage:(UIImage *)image withRadius:(CGFloat)radius needCropSquare:(BOOL)needCropSquare;

@end
