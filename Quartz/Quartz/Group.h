//
//  Group.h
//  Quartz
//
//  Created by Chen XiaoLiang on 12-12-25.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic) NSTimeInterval recordTimestamp;
@property (nonatomic, retain) NSString * smallPosterImage;
@property (nonatomic, retain) NSString * largePosterImage;
@property (nonatomic, retain) NSString * posterItemID;
@property (nonatomic, retain) NSSet *items;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
