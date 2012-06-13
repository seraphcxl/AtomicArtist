//
//  DCUpdateGroupOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCUpdateGroupOperation.h"
#import "DCDataModelCommonDefine.h"
#import "Group.h"

@implementation DCUpdateGroupOperation

- (void)main {
    do {
        UIImage *posterImage = [_arg objectForKey:GROUP_POSTERIMAGE];
        NSString *posterItemUID = [_arg objectForKey:GROUP_POSTERIMAGEITEMUID];
        
        Group *group = [_arg objectForKey:GROUP];
        if (group) {
            group.posterItemUID = posterItemUID;
            group.posterImage = posterImage;
            group.posterImageData = UIImagePNGRepresentation(posterImage);
            group.inspectionRecord = [NSDate date];
        }
    } while (NO);
}

@end
