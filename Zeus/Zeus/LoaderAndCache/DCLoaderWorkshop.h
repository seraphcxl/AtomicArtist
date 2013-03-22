//
//  DCLoaderWorkshop.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"

typedef enum {
    DCLoaderUID_ImagePicker_Group = 0,
    DCLoaderUID_ImagePicker_Item,
    DCLoaderUID_FaceFeature,
    DCLoaderUID_WhipView,
    
    DCLoaderUID_Count,
} DCLoaderUID;

@interface DCLoaderWorkshop : NSObject {
}

DEFINE_SINGLETON_FOR_HEADER(DCLoaderWorkshop);

- (NSOperationQueue *)pipeline:(DCLoaderUID)uniqueID;
- (void)addOperation:(NSOperation *)opt toPipeline:(DCLoaderUID)uniqueID;
- (void)shutDownPipeline:(DCLoaderUID)uniqueID;

@end
