//
//  DCALAssetsLibrary.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniformDataProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCAssetsLibAgent.h"

@interface DCALAssetsLibrary : NSObject <DCDataLibrary, DCAssetsLibUser>

@end
