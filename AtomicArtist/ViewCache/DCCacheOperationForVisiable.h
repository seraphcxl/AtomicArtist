//
//  DCCacheOperationForVisiable.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 7/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCDataLoader.h"

@protocol DCCacheOperationForVisiableDelegate <NSObject>

- (void)createViewsAndLoadSmallThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end except:(NSInteger)current andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForCurrentTableCell:(NSInteger)index andCancelFlag:(BOOL *)cancel;
- (void)loadBigThumbnailForVisiableFrom:(NSInteger)begin to:(NSInteger)end except:(NSInteger)current andCancelFlag:(BOOL *)cancel;

@end

@interface DCCacheOperationForVisiable : NSOperation {
    BOOL _canceled;
    BOOL _finished;
}
@property (assign, nonatomic) id<DCCacheOperationForVisiableDelegate> delegate;
@property (assign, nonatomic) id<DCDataLoaderMgrDelegate> delegateForDCDataLoaderMgr;

@property (assign, nonatomic) NSInteger currentTableCellIndex;

@property (assign, nonatomic) NSInteger visiableBeginTableCellIndex;
@property (assign, nonatomic) NSInteger visiableEndTableCellIndex;

@end
