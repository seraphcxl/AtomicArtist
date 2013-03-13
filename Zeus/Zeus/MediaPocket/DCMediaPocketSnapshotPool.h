//
//  DCMediaPocketSnapshotPool.h
//  Whip
//
//  Created by Chen XiaoLiang on 13-2-19.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"
#import "DCMediaPocket.h"

@interface DCMediaPocketSnapshotPool : NSObject {
    
}

DEFINE_SINGLETON_FOR_HEADER(DCMediaPocketSnapshotPool);

- (NSArray *)allKeysForSnapshots;
- (DCMediaPocket *)mediaPocket:(NSString *)uniqueID;
- (void)insertSnapshot:(DCMediaPocket *)mediaPocket;
- (void)removeSnapshot:(NSString *)uniqueID;

@end
