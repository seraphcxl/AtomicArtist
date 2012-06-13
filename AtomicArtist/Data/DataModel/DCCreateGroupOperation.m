//
//  DCCreateGroupOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCCreateGroupOperation.h"
#import "DCDataModelCommonDefine.h"
#import "Group.h"

@implementation DCCreateGroupOperation

- (void)main {
    do {
        NSString *groupUID = [_arg objectForKey:GROUP_UID];
        UIImage *posterImage = [_arg objectForKey:GROUP_POSTERIMAGE];
        NSString *posterItemUID = [_arg objectForKey:GROUP_POSTERIMAGEITEMUID];
        
        if (![_arg objectForKey:GROUP]) {
            Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
            
            group.uniqueID = groupUID;
            group.posterItemUID = posterItemUID;
            group.posterImage = posterImage;
            group.posterImageData = UIImagePNGRepresentation(posterImage);
        }
    } while (NO);
}

@end
