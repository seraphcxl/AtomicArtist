//
//  DCCacheOperationForBuffer.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCDataLoader.h"

@protocol DCCacheOperationForBufferDelegate <NSObject>

- (void)createViewsAndLoadSmallThumbnailForBufferWithPrevIndexs:(NSArray *)prevIndexs nextIndexs:(NSArray *)nextIndexs andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForBufferWithPrevIndexs:(NSArray *)prevIndexs nextIndexs:(NSArray *)nextIndexs andCancelFlag:(BOOL *)cancel;
- (void)clearCacheWithBufferRangeFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;

@end

@interface DCCacheOperationForBuffer : NSOperation {
    BOOL _canceled;
    BOOL _finished;
}
@property (assign, nonatomic) id<DCCacheOperationForBufferDelegate> delegate;
@property (assign, nonatomic) id<DCDataLoaderMgrDelegate> delegateForDCDataLoaderMgr;

@property (assign, nonatomic) NSInteger bufferBeginTableCellIndex;
@property (assign, nonatomic) NSInteger bufferEndTableCellIndex;

@property (assign, nonatomic) NSInteger visiableBeginTableCellIndex;
@property (assign, nonatomic) NSInteger visiableEndTableCellIndex;

@property (assign, nonatomic) BOOL needClearCache;

@end
