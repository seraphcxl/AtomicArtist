//
//  Item.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDate * inspectionRecord;
@property (nonatomic, retain) UIImage * thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) Group *group;

@end
