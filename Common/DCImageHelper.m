//
//  DCImageHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCImageHelper.h"

#define MIRRORED ((orient == UIImageOrientationUpMirrored) || (orient == UIImageOrientationLeftMirrored) || (orient == UIImageOrientationRightMirrored) || (orient == UIImageOrientationDownMirrored))	
#define ROTATED90	((orient == UIImageOrientationLeft) || (orient == UIImageOrientationLeftMirrored) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationRightMirrored))

@implementation DCImageHelper

+ (NSInteger)UIImageOrientationToCGImagePropertyOrientation:(UIImageOrientation)imageOrientation {
    NSInteger result = 0;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            result = 1;
            break;
            
        case UIImageOrientationDown:
            result = 3;
            break;
            
        case UIImageOrientationLeft:
            result = 8;
            break;
            
        case UIImageOrientationRight:
            result = 6;
            break;
            
        case UIImageOrientationUpMirrored:
            result = 2;
            break;
            
        case UIImageOrientationDownMirrored:
            result = 4;
            break;
            
        case UIImageOrientationLeftMirrored:
            result = 5;
            break;
            
        case UIImageOrientationRightMirrored:
            result = 7;
            break;
            
        default:
            break;
    }
    return result;
}

+ (CGImageSourceRef)loadImageSourceFromContentsOfFile:(NSString *)path {
    CGImageSourceRef result = nil;
    CGDataProviderRef cgDP = nil;
    do {
        if (!path) {
            break;
        }
        cgDP = CGDataProviderCreateWithFilename([path fileSystemRepresentation]);
        result = CGImageSourceCreateWithDataProvider(cgDP, NULL);
    } while (NO);
    if (cgDP) {
        CGDataProviderRelease(cgDP);
        cgDP = nil;
    }
    return result;
}

+ (CGImageRef)loadImageFromContentsOfFile:(NSString *)path withMaxPixelSize:(CGFloat)pixelSize {
    CGImageRef result = nil;
    CGImageSourceRef sourceRef = nil;
    do {
        if (!path || pixelSize == 0) {
            break;
        }
        sourceRef = [DCImageHelper loadImageSourceFromContentsOfFile:path];
        if (!sourceRef) {
            break;
        }
        NSDictionary *options = nil;
        if (pixelSize > 0.0f) {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, (id)[NSNumber numberWithDouble:pixelSize], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
        } else {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, nil];
        }
        result = CGImageSourceCreateImageAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
    } while (NO);
    if (sourceRef) {
        CFRelease(sourceRef);
        sourceRef = nil;
    }
    return result;
}

#ifdef ALASSETLIB_AVAILABLE
+ (CGImageSourceRef)loadImageSourceFromALAsset:(ALAsset *)asset {
    CGImageSourceRef result = nil;
    do {
        if (!asset) {
            break;
        }
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        Byte *buffer = (Byte *)malloc(representation.size);
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        result = CGImageSourceCreateWithData((__bridge CFDataRef)data,  NULL);
    } while (NO);
    return result;
}

+ (CGImageRef)loadImageFromALAsset:(ALAsset *)asset withMaxPixelSize:(CGFloat)pixelSize {
    CGImageRef result = nil;
    CGImageSourceRef sourceRef = nil;
    do {
        if (!asset || pixelSize == 0) {
            break;
        }
        sourceRef = [DCImageHelper loadImageSourceFromALAsset:asset];
        if (!sourceRef) {
            break;
        }
        NSDictionary *options = nil;
        if (pixelSize > 0.0f) {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, (id)[NSNumber numberWithDouble:pixelSize], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
        } else {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, nil];
        }
        result = CGImageSourceCreateImageAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        SAFE_ARC_SAFERELEASE(options);
    } while (NO);
    if (sourceRef) {
        CFRelease(sourceRef);
        sourceRef = nil;
    }
    return result;
}

+ (UIImage *)loadImageFromALAsset:(ALAsset *)asset withShape:(DCImageShapeType)type andMaxPixelSize:(CGFloat)pixelSize {
    UIImage *result = nil;
    CGImageSourceRef sourceRef = nil;
    CGImageRef cgimage = nil;
    do {
        if (!asset || pixelSize == 0) {
            break;
        }
        
        double size = -1.0;
        switch (type) {
            case DCImageShapeType_Original:
                size = pixelSize;
                break;
                
            case DCImageShapeType_Square:
                size = pixelSize * 2.0;
                break;
                
            default:
                break;
        }
        if (size < 0.0) {
            break;
        }
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        Byte *buffer = (Byte *)malloc(representation.size);
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data,  NULL);
        NSDictionary *options = nil;
        if (pixelSize > 0.0f) {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, (id)[NSNumber numberWithDouble:pixelSize], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
        } else {
            options = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways, nil];
        }
        cgimage = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        SAFE_ARC_SAFERELEASE(options);
        
        size_t imgWidth = CGImageGetWidth(cgimage);
        size_t imgHeight = CGImageGetHeight(cgimage);
        if (imgWidth != 0 && imgHeight != 0) {
            result = [UIImage imageWithCGImage:cgimage];
        } else {
            result = [UIImage imageWithCGImage:[representation fullScreenImage]];
        }
        
        switch (type) {
            case DCImageShapeType_Original:
            {
                CGSize sizeOfImg = result.size;
                CGSize sizeOfFrame;
                BOOL needResize = NO;
                if (sizeOfImg.width > sizeOfImg.height) {
                    if (sizeOfImg.width > pixelSize) {
                        sizeOfFrame.width = pixelSize;
                        sizeOfFrame.height = (sizeOfImg.height * (sizeOfFrame.width * 1.0 / sizeOfImg.width));
                        needResize = YES;
                    }
                } else {
                    if (sizeOfImg.height > pixelSize) {
                        sizeOfFrame.height = pixelSize;
                        sizeOfFrame.width = (sizeOfImg.width * (sizeOfFrame.height * 1.0 / sizeOfImg.height));
                        needResize = YES;
                    }
                }
                if (needResize) {
                    result = [DCImageHelper image:result fitInSize:sizeOfFrame];
                }
            }
                break;
                
            case DCImageShapeType_Square:
            {
                CGSize newSize;
                newSize.width = newSize.height = pixelSize;
                result = [DCImageHelper image:result fillSize:newSize];
            }
                break;
                
            default:
                break;
        }
        
    } while (NO);
    if (cgimage) {
        CGImageRelease(cgimage);
        cgimage = nil;
    }
    if (sourceRef) {
        CFRelease(sourceRef);
        sourceRef = nil;
    }
    return result;
}
#endif

+ (UIImage *)bezierImage:(UIImage *)image withRadius:(CGFloat)radius needCropSquare:(BOOL)needCropSquare {
    UIImage *result = nil;
    do {
        CGSize origImageSize = [image size];
        
        CGRect newRect;
        newRect.origin = CGPointZero;
        if (needCropSquare) {
            CGFloat size = MIN(origImageSize.width, origImageSize.height);
            newRect.size.width = size;
            newRect.size.height = size;
        } else {
            newRect.size = origImageSize;
        }
        
        UIGraphicsBeginImageContext(newRect.size);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:radius];
        [path addClip];
        
        CGRect projectRect;
        projectRect.size = origImageSize;
        projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
        projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
        
        [image drawInRect:projectRect];
        
        result = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    } while (NO);
    return result;
}

+ (CGImageRef)createGradientImage:(CGSize)size {
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
	// Create gradient in gray device color space
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// Draw the linear gradient
	CGPoint p1 = CGPointZero;
	CGPoint p2 = CGPointMake(0, size.height);
	CGContextDrawLinearGradient(context, gradient, p1, p2, kCGGradientDrawsAfterEndLocation);
	
	// Return the CGImage
	CGImageRef theCGImage = CGBitmapContextCreateImage(context);
	CFRelease(gradient);
	CGContextRelease(context);
    return theCGImage;
}

+ (UIImage *)reflectionOfView:(UIView *)view withPercent:(CGFloat)percent {
	// Retain the width but shrink the height
	CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height * percent);
	
	// Shrink the view
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[view.layer renderInContext:context];
	UIImage *partialimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// build the mask
	CGImageRef mask = [self createGradientImage:size];
	CGImageRef ref = CGImageCreateWithMask(partialimg.CGImage, mask);
	UIImage *theImage = [UIImage imageWithCGImage:ref];
	CGImageRelease(ref);
	CGImageRelease(mask);
	return theImage;
}

const CGFloat kReflectDistance = 10.0f;

+ (void)addReflectionToView:(UIView *)view
{
	view.clipsToBounds = NO;
	UIImageView *reflection = [[UIImageView alloc] initWithImage:[self reflectionOfView:view withPercent: 0.45f]];
	CGRect frame = reflection.frame;
	frame.origin = CGPointMake(0.0f, view.frame.size.height + kReflectDistance);
	reflection.frame = frame;
	[view addSubview:reflection];
    SAFE_ARC_SAFERELEASE(reflection);
}

const CGFloat kReflectPercent = 0.5f;
const CGFloat kReflectOpacity = 0.5f;

+ (void)addSimpleReflectionToView:(UIView *)view
{
	CALayer *reflectionLayer = [CALayer layer];
	reflectionLayer.contents = [view layer].contents;
	reflectionLayer.opacity = kReflectOpacity;
	reflectionLayer.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height * kReflectPercent);
	CATransform3D stransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
	CATransform3D transform = CATransform3DTranslate(stransform, 0.0f, -(kReflectDistance + view.frame.size.height), 0.0f);
	reflectionLayer.transform = transform;
	reflectionLayer.sublayerTransform = reflectionLayer.transform;
	[[view layer] addSublayer:reflectionLayer];
}

+ (CGSize)fitSize: (CGSize)thisSize inSize: (CGSize)aSize {
	CGFloat scale;
	CGSize newsize = thisSize;
	
	if (newsize.height && (newsize.height > aSize.height)) {
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= aSize.width)) {
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

+ (CGSize)fitoutSize:(CGSize)thisSize inSize:(CGSize)aSize {
	CGFloat scale;
	CGSize newsize = thisSize;
	
	if (newsize.height && (newsize.height > aSize.height)) {
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width < aSize.width)) {
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

+ (CGRect)frameSize: (CGSize)thisSize inSize:(CGSize)aSize {
	CGSize size = [self fitSize:thisSize inSize:aSize];
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize {
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:[self frameSize:image.size inSize:viewsize]];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image fillSize:(CGSize)viewsize {
	CGSize size = image.size;
	
	CGFloat scalex = viewsize.width / size.width;
	CGFloat scaley = viewsize.height / size.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	UIGraphicsBeginImageContext(viewsize);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((viewsize.width - width) / 2.0f);
	float dheight = ((viewsize.height - height) / 2.0f);
    
	CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image centerInSize:(CGSize)viewsize {
	CGSize size = image.size;
	
	UIGraphicsBeginImageContext(viewsize);
	float dwidth = (viewsize.width - size.width) / 2.0f;
	float dheight = (viewsize.height - size.height) / 2.0f;
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * M_PI / 180;
}

+ (UIImage *)image:(UIImage *)image rotatedByDegrees:(CGFloat)degrees {  
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation([self degreesToRadians:degrees]);
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.bounds.size;
    SAFE_ARC_SAFERELEASE(rotatedViewBox);
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, [self degreesToRadians:degrees]);
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
	CGImageRef src = [image CGImage];
	CGImageRef dst = CGImageCreateWithImageInRect(src,rect);
	UIImage *newImage = [UIImage imageWithCGImage:dst];
    CGImageRelease(dst);
	return newImage;
}

+ (UIImage *)doUnrotateImage: (UIImage *)image fromOrientation:(UIImageOrientation)orient {
	CGSize size = image.size;
	if (ROTATED90) {
        size = CGSizeMake(image.size.height, image.size.width);
    }
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Rotate as needed
	switch(orient) {  
        case UIImageOrientationLeft:
		case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, 0.0f, -size.width);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
        }
            break;
        case UIImageOrientationRight: 
		case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformRotate(transform, -M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, -size.height, 0.0f);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
        }
            break;
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformRotate(transform, M_PI);
			transform = CGAffineTransformTranslate(transform, -size.width, -size.height);
			CGContextConcatCTM(context, transform);
        }
			break;
        default:  
			break;
    }
	if (MIRRORED) {
		// de-mirror
		transform = CGAffineTransformMakeTranslation(size.width, 0.0f);
		transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
		CGContextConcatCTM(context, transform);
	}
    
	// Draw the image into the transformed context and return the image
	[image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

@end
