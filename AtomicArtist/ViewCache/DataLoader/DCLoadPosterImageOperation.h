//
//  DCLoadPosterImageOperation.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadThumbnailOperation.h"

extern NSString * const NOTIFY_POSTERIMAGELOADED;

@interface DCLoadPosterImageOperation : DCLoadThumbnailOperation

@property (readonly, nonatomic) NSString *dataGroupUID;

- (id)initWithItemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID;

@end
