//
//  DCLoadThumbnailOperation.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NOTIFY_THUMBNAILLOADED;

@interface DCLoadThumbnailOperation : NSOperation {
    BOOL _canceled;
}

@property (retain, nonatomic) UIImage *thumbnail;
@property (readonly, nonatomic) NSString *itemUID;

- (id)initWithItemUID:(NSString *)itemUID;

@end
