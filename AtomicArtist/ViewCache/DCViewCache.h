//
//  DCViewCache.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import "DCCacheOperationForVisiable.h"
#import "DCCacheOperationForBuffer.h"

@protocol DCViewCacheDelegate <NSObject>

- (NSMutableArray *)getViewUIDsForTableCellAtIndexPath:(NSUInteger)index;
- (UIView *)createViewWithUID:(NSString *)uid;

- (NSUInteger)visiableCellCount;

- (NSUInteger)tableCellCount;

- (void)loadSmallThumbnailForView:(UIView *)view;
- (void)loadBigThumbnailForView:(UIView *)view;

@end

@interface DCViewCache : NSObject <DCCacheOperationForVisiableDelegate, DCCacheOperationForBufferDelegate> {
    NSMutableDictionary *_tableCells;  // key:UIDForIndexPath; value:NSMutableDictionary *viewsInTableCell
//    NSMutableDictionary *_views;  // key:UIDForView; value:view
    NSLock *_lockForViews;
    
    NSOperationQueue *_queueForVisiableOp;
    NSOperationQueue *_queueForBufferOp;
}

@property (assign, nonatomic) id<DCViewCacheDelegate> delegate;

@property (assign, nonatomic) NSUInteger lastRequireBufferIndex;

@property (assign, nonatomic) NSUInteger bufferTableCellNumber;

@property (assign, nonatomic) id<DCDataLibraryHelper> dataLibraryHelper;

//- (UIView *)getViewWithUID:(NSString *)uid;

- (NSArray *)getViewsForTableCell:(NSIndexPath *)indexPath;

- (NSString *)uidForView:(UIView *)view;

@end
