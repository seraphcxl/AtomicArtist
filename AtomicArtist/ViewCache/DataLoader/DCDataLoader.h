//
//  DCDataLoader.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DATALODER_TYPE {
    DATALODER_TYPE_VISIABLE = 1,
    DATALODER_TYPE_BUFFER = 2
};

@protocol DCDataLoaderMgrDelegate <NSObject>

- (void)queue:(enum DATALODER_TYPE)type addOperation:(NSOperation *)operation;
- (void)cancelAllOperationsOnQueue:(enum DATALODER_TYPE)type;
- (void)terminateAllOperationsOnQueue:(enum DATALODER_TYPE)type;
- (void)queue:(enum DATALODER_TYPE)type pauseWithAutoResume:(BOOL)enable with:(NSTimeInterval)seconds;

@end

@interface DCDataLoader : NSObject

- (void)queue:(enum DATALODER_TYPE)type addOperation:(NSOperation *)operation;

- (void)cancelAllOperationsOnQueue:(enum DATALODER_TYPE)type;

- (void)terminateAllOperationsOnQueue:(enum DATALODER_TYPE)type;

- (NSUInteger)operationCountOnQueue:(enum DATALODER_TYPE)type;

- (NSInteger)maxConcurrentOperationCountOnQueue:(enum DATALODER_TYPE)type;

- (void)queue:(enum DATALODER_TYPE)type pauseWithAutoResume:(BOOL)enable with:(NSTimeInterval)seconds;

- (BOOL)isSuspendedQueue:(enum DATALODER_TYPE)type;

@end
