//
//  Group.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSDate * inspectionRecord;
@property (nonatomic, retain) NSString * posterItemUID;
@property (nonatomic, retain) UIImage * posterImage;
@property (nonatomic, retain) NSData * posterImageData;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *items;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
