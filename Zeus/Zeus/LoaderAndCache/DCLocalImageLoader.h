//
//  DCLocalImageLoader.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCRevokableLoader.h"
#import <CoreGraphics/CoreGraphics.h>

extern NSString * const NOTIFY_LOCALIMAGELOADER_DOWNLOAD_DONE;
extern NSString * const NOTIFY_LOCALIMAGELOADER_DOWNLOAD_ERROR;

@interface DCLocalImageLoader : DCRevokableLoader

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, readonly) CGImageRef cgImgRef;

@end
