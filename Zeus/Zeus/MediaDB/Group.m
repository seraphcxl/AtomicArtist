//
//  Group.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-26.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "Group.h"
#import "Item.h"


#pragma mark - implementation Group
@implementation Group

@dynamic largePosterImage;
@dynamic posterItemID;
@dynamic recordTimestamp;
@dynamic smallPosterImage;
@dynamic uniqueID;
@dynamic items;

- (void)awakeFromFetch {
    do {
        [super awakeFromFetch];
    } while (NO);
}

- (void)awakeFromInsert {
    do {
        [super awakeFromInsert];
        
        self.recordTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    } while (NO);
}

#pragma mark - Group - CoreDataGeneratedAccessors
- (void)addItemsObject:(NSManagedObject *)value {
    do {
        if (!value) {
            break;
        }
        
        if (![value isMemberOfClass:[Item class]]) {
            break;
        }
        
        @synchronized(self.items) {
            NSMutableSet *newSet = [NSMutableSet setWithSet:self.items];
            [newSet addObject:value];
            self.items = newSet;
        }
    } while (NO);
}

- (void)removeItemsObject:(Item *)value {
    do {
        if (!value) {
            break;
        }
        
        if (![value isMemberOfClass:[Item class]]) {
            break;
        }
        
        @synchronized(self.items) {
            NSMutableSet *newSet = [NSMutableSet setWithSet:self.items];
            [newSet removeObject:value];
            self.items = newSet;
        }
    } while (NO);
}


- (void)addItems:(NSSet *)values {
    do {
        if (!values) {
            break;
        }
        
        if ([values count] == 0) {
            break;
        }
        
        @synchronized(self.items) {
            NSMutableSet *newSet = [NSMutableSet setWithSet:self.items];
            [newSet minusSet:values];
            [newSet addObjectsFromArray:[values allObjects]];
            self.items = newSet;
        }
    } while (NO);
}

- (void)removeItems:(NSSet *)values {
    do {
        if (!values) {
            break;
        }
        
        if ([values count] == 0) {
            break;
        }
        
        @synchronized(self.items) {
            NSMutableSet *newSet = [NSMutableSet setWithSet:self.items];
            [newSet minusSet:values];
            self.items = newSet;
        }
    } while (NO);
}


@end
