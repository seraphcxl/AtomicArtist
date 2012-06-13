//
//  DCGetGroupOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCGetGroupOperation.h"
#import "DCDataModelCommonDefine.h"

@implementation DCGetGroupOperation

- (void)main {
    do {
        NSString *groupUID = [_arg objectForKey:GROUP_UID];
        
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        
        NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Group"];
        [request setEntity:entityDescription];
        
        [request setSortDescriptors:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID like %@", groupUID];
        [request setPredicate:predicate];
        
        NSError *err = nil;
        NSArray *result = [_context executeFetchRequest:request error:&err];
        if (!result) {
            [NSException raise:@"DCGetGroupOperation error" format:@"Reason: %@", [err localizedDescription]];
        }
        
        if ([result count] == 0) {
            ;
        } else {
            if ([result count] != 1) {
                [NSException raise:@"DCGetGroupOperation error" format:@"Reason: The result count for get album from AtomicArtistModel != 1"];
            }
            [_arg setObject:[result objectAtIndex:0] forKey:GROUP];
        }
    } while (NO);
}

@end
