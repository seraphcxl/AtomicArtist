//
//  DCDataLoader.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDataLoader : NSObject

+ (id)defaultDataLoader;

+ (void)staticRelease;

- (void)addOperation:(NSOperation *)operation;

- (void)cancelAllOperations;

- (NSUInteger)operationCount;

- (NSInteger)maxConcurrentOperationCount;
- (void)setMaxConcurrentOperationCount:(NSInteger)cnt;

- (void)setSuspended:(BOOL)b;
- (BOOL)isSuspended;

@end
