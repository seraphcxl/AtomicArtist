//
//  DCImageInMemCache.h
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12-12-27.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"

#define IMAGEINMEMCACHE_MAXCOUNT 500

@interface DCImageInMemCache : NSObject {
}

+ (DCImageInMemCache *)defaultImageInMemCache;
+ (void)staticRelease;

- (void)resetCache;

- (UIImage *)imageFoeKey:(NSString *)key;
- (BOOL)cacheImage:(UIImage *)image ForKey:(NSString *)key;

@end
