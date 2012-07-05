//
//  DCViewCacheOperation.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCViewCacheOperationDelegate <NSObject>

- (void)loadBigThumbnailForVisiableTableCellFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;
- (void)createViewsAndLoadSmallThumbnailForPreviousBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;
- (void)createViewsAndLoadSmallThumbnailForNextBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForPreviousBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForNextBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;

- (void)clearCacheWithBufferRangeFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;

@end

@interface DCViewCacheOperation : NSOperation {
    BOOL _canceled;
}

@property (assign, nonatomic) id<DCViewCacheOperationDelegate> delegate;

@property (assign, nonatomic) NSInteger currentTableCellIndex;

@property (assign, nonatomic) NSInteger bufferBeginTableCellIndex;
@property (assign, nonatomic) NSInteger bufferEndTableCellIndex;

@property (assign, nonatomic) NSInteger visiableBeginTableCellIndex;
@property (assign, nonatomic) NSInteger visiableEndTableCellIndex;


@property (assign, nonatomic) BOOL needClearCache;

@end
