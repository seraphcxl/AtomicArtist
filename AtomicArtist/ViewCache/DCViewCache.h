//
//  DCViewCache.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import "DCViewCacheOperation.h"

@protocol DCViewCacheDelegate <NSObject>

- (NSArray *)getViewUIDsForTableCellAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)visiableCellCount;

- (NSUInteger)tableCellCount;

- (void)loadSmallThumbnailForView:(UIView *)view;
- (void)loadBigThumbnailForView:(UIView *)view;

@end

@interface DCViewCache : NSObject <DCViewCacheOperationDelegate> {
    NSMutableDictionary *_tableCells;  // key:UIDForIndexPath; value:NSMutableDictionary *viewsInTableCell
    NSMutableDictionary *_views;  // key:UIDForView; value:view
    NSLock *_lockForViews;
    
    NSOperationQueue *_queueForCacheOp;
    NSOperationQueue *_queueForLoadCurrentTableCellBigThumbnailOp;
}

@property (assign, nonatomic) id<DCViewCacheDelegate> delegate;

@property (assign, nonatomic) NSUInteger lastRequireBufferIndex;

@property (assign, nonatomic) NSUInteger bufferTableCellNumber;
@property (assign, nonatomic) NSUInteger bufferFrequency;  // bufferFrequency <= bufferRowNumber / 2

@property (assign, nonatomic) id<DCDataLibraryHelper> dataLibraryHelper;

- (UIView *)getViewWithUID:(NSString *)uid;

- (void)addVisiableTableCell:(NSIndexPath *)indexPath;

@end
