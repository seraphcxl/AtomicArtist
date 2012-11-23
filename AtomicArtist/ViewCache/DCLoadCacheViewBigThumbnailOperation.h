//
//  DCLoadCacheViewBigThumbnailOperation.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCDataLoader.h"
@protocol DCLoadCacheViewBigThumbnailOperationDelegate <NSObject>

- (void)loadBigThumbnailForCacheViewsCancelFlag:(BOOL *)cancel;

@end

@interface DCLoadCacheViewBigThumbnailOperation : NSOperation {
    BOOL _canceled;
    BOOL _finished;
}

@property (assign, nonatomic) id<DCLoadCacheViewBigThumbnailOperationDelegate> delegate;
@property (assign, nonatomic) id<DCDataLoaderMgrDelegate> delegateForDCDataLoaderMgr;

@end
