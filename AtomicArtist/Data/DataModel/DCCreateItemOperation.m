//
//  DCCreateItemOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCCreateItemOperation.h"
#import "DCDataModelCommonDefine.h"
#import "Item.h"

@implementation DCCreateItemOperation

- (void)main {
    do {
        NSString *itemUID = [_arg objectForKey:ITEM_UID];
        UIImage *thumbnail = [_arg objectForKey:ITEM_THUMBNAIL];
        
        if (![_arg objectForKey:ITEM]) {
            Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_context];
            
            item.uniqueID = itemUID;
            item.thumbnail = thumbnail;
            item.thumbnailData = UIImagePNGRepresentation(thumbnail);
        }
    } while (NO);
}

@end
