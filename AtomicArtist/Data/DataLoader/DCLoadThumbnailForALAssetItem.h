//
//  DCLoadThumbnailForALAssetItem.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"

@class DCLoadThumbnailForALAssetItem;

@protocol DCLoadThumbnailForALAssetItemDeleGate <NSObject>

- (void)notifySuceed:(DCLoadThumbnailForALAssetItem *)operation;

@end

@interface DCLoadThumbnailForALAssetItem : NSOperation

@property (assign, nonatomic) id <DCLoadThumbnailForALAssetItemDeleGate> delegate;
@property (retain, nonatomic) id <DCDataItem> dataItem;

- (id)initWithDataItem:(id <DCDataItem>)dataItem;

@end
