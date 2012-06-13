//
//  DCGetItemOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCGetItemOperation.h"
#import "DCDataModelCommonDefine.h"

@implementation DCGetItemOperation

- (void)main {
    do {
        NSString *itemUID = [_arg objectForKey:ITEM_UID];
        
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        
        NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Item"];
        [request setEntity:entityDescription];
        
        [request setSortDescriptors:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID like %@", itemUID];
        [request setPredicate:predicate];
        
        NSError *err = nil;
        NSArray *result = [_context executeFetchRequest:request error:&err];
        if (!result) {
            [NSException raise:@"DCGetItemOperation error" format:@"Reason: %@", [err localizedDescription]];
        }
        
        if ([result count] == 0) {
            ;
        } else {
            if ([result count] != 1) {
                [NSException raise:@"DCGetItemOperation error" format:@"Reason: The result count for get item from AtomicArtistModel != 1"];
            }
            [_arg setObject:[result objectAtIndex:0] forKey:ITEM];
        }
    } while (NO);
}

@end
