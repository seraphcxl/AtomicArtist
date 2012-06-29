//
//  DCViewCache.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCViewCache : NSObject

- (UIView *)getViewWithUID:(NSString *)uid;

- (void)addView:(UIView *)view withUID:(NSString *)uid inRow:(NSIndexPath *)indexPath;

@end
