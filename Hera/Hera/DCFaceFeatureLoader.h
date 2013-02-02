//
//  DCFaceFeatureLoader.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-23.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCRevokableLoader.h"
#import <CoreGraphics/CoreGraphics.h>

extern NSString * const NOTIFY_FACEFEATURELOADER_DONE;

@interface DCFaceFeatureLoader : DCRevokableLoader

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) CGFloat pixelSize;

@end
