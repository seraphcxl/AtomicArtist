//
//  Album.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/6/12.
//  Copyright (c) 2012 seraphCXL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * posterAssetURLString;
@property (nonatomic, retain) UIImage * posterImage;
@property (nonatomic, retain) NSData * posterImageData;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSDate * inspectionRecord;
@property (nonatomic, retain) NSSet *assets;

+ (CGSize)posterImageSize;

@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

@end
