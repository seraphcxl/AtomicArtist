//
//  Item.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-23.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSData * faceFeatureData;
@property (nonatomic, retain) NSMutableArray * faceFeatureArray;
@property (nonatomic, retain) NSString * largeThumbnail;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * previewImage;
@property (nonatomic) NSTimeInterval recordTimestamp;
@property (nonatomic, retain) NSString * smallThumbnail;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) Group *group;

@end
