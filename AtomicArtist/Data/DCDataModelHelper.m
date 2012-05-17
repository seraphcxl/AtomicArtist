//
//  DCDataModelHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCDataModelHelper.h"
#import "Group.h"
#import "Item.h"

static DCDataModelHelper *staticDefaultDataModelHelper = nil;

@interface DCDataModelHelper () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}

@end

@implementation DCDataModelHelper

#pragma mark item
- (Item *)getItemWithUID:(NSString *)itemUID {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Item"];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID like %@", itemUID];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] != 1) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: The result count for get asset from AtomicArtistModel != 1"];
    }
    
    return [result objectAtIndex:0];
}

- (void)createItemWithUID:(NSString *)itemUID andThumbnail:(UIImage *)thumbnail {
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_context];
    
    item.uniqueID = itemUID;
    item.thumbnail = thumbnail;
    item.thumbnailData = UIImagePNGRepresentation(thumbnail);
}

#pragma mark group
- (Group *)getGroupWithUID:(NSString *)groupUID {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Group"];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID like %@", groupUID];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] != 1) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: The result count for get album from AtomicArtistModel != 1"];
    }
    
    return [result objectAtIndex:0];
}

- (void)createGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
    
    group.uniqueID = groupUID;
    group.posterItemUID = posterItemUID;
    group.posterImage = posterImage;
    group.posterImageData = UIImagePNGRepresentation(posterImage);
}

- (void)updateGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    Group *group = [self getGroupWithUID:groupUID];
    if (group) {
        group.posterItemUID = posterItemUID;
        group.posterImage = posterImage;
        group.posterImageData = UIImagePNGRepresentation(posterImage);
        group.inspectionRecord = [NSDate date];
    } else {
        group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
        
        group.uniqueID = groupUID;
        group.posterItemUID = posterItemUID;
        group.posterImage = posterImage;
        group.posterImageData = UIImagePNGRepresentation(posterImage);
    }
}

#pragma mark DCDataModelHelper
+ (DCDataModelHelper *)defaultDataModelHelper {
    if (!staticDefaultDataModelHelper) {
        staticDefaultDataModelHelper = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultDataModelHelper;
}

+ (void)staticRelease {
    if (staticDefaultDataModelHelper) {
        [staticDefaultDataModelHelper release];
        staticDefaultDataModelHelper = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultDataModelHelper];
}

- (id)init {
    self = [super init];
    if (self) {                
        // Read in Homepwner.xcdatamodeld
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog(@"model = %@", model);
        
        NSPersistentStoreCoordinator *psc = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model] autorelease];
        
        // Where does the SQLite file go?    
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path]; 
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            [NSException raise:@"AADataStore error" format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [_context setUndoManager:nil];
    }
    return self;
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"dataModel.data"];
}

- (BOOL)saveChanges {
    NSError *err = nil;
    BOOL successful = [_context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}


@end
