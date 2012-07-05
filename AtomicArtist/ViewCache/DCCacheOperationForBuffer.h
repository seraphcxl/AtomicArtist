//
//  DCCacheOperationForBuffer.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCCacheOperationForBufferDelegate <NSObject>

- (void)createViewsAndLoadSmallThumbnailForBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForBufferFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;

- (void)clearCacheWithBufferRangeFrom:(NSInteger)begin to:(NSInteger)end andCancelFlag:(BOOL *)cancel;

@end

@interface DCCacheOperationForBuffer : NSOperation {
    BOOL _canceled;
}
@property (assign, nonatomic) id<DCCacheOperationForBufferDelegate> delegate;

@property (assign, nonatomic) NSInteger bufferBeginTableCellIndex;
@property (assign, nonatomic) NSInteger bufferEndTableCellIndex;

@property (assign, nonatomic) NSInteger visiableBeginTableCellIndex;
@property (assign, nonatomic) NSInteger visiableEndTableCellIndex;

@end
