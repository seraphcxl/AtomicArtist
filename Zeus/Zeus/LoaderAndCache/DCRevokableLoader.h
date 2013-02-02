//
//  DCRevokableLoader.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCRevokableLoader : NSOperation {
}

@property (atomic, assign, getter = isRevoke) BOOL revoke;

@end
