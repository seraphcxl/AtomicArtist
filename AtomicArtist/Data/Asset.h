//
//  Asset.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/6/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Asset : NSManagedObject

@property (nonatomic, retain) UIImage * thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSDate * inspectionRecord;
@property (nonatomic, retain) Album *album;

+ (CGSize)thumbnailSize;

@end
