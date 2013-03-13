//
//  DCALAssetsLibraryBase.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCAssetsLibAgent.h"

@interface DCALAssetsLibraryBase : NSObject <DCDataLibraryBase, DCAssetsLibUser> {
    NSMutableArray *_allALAssetsGroupUIDs;
    NSMutableDictionary *_allALAssetsGroups; // Key:(NSString *)UID Value:(DCDataGroupBase *)assetsGroup
    NSUInteger _frequency;
    NSUInteger _enumCount;
    
    BOOL _cancelEnum;
    BOOL _enumerating;
}

- (void)initAssetsLib;
- (void)uninitAssetsLib;
- (void)insertGroup:(id<DCDataGroupBase>)group forUID:(NSString *)uid;

@end
