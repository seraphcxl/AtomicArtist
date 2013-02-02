//
//  DCWebImageLoader.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCRevokableLoader.h"

extern NSString * const NOTIFY_WEBIMAGELOADER_DOWNLOAD_DONE;
extern NSString * const NOTIFY_WEBIMAGELOADER_DOWNLOAD_ERROR;

@interface DCWebImageLoader : DCRevokableLoader

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, SAFE_ARC_PROP_STRONG) NSMutableData *downloadData;

@end
