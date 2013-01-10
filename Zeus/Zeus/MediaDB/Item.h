//
//  Item.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-10.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * largeThumbnail;
@property (nonatomic, retain) NSString * previewImage;
@property (nonatomic) NSTimeInterval recordTimestamp;
@property (nonatomic, retain) NSString * smallThumbnail;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) Group *group;

@end
