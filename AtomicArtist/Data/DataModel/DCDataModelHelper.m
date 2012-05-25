//
//  DCDataModelHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCDataModelHelper.h"
#import "Group.h"
#import "Item.h"

static DCDataModelHelper *staticDefaultDataModelHelper = nil;

@interface DCDataModelHelper () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
    NSLock *_lockForDataModel;
}

@end

@implementation DCDataModelHelper

#pragma mark item
- (Item *)getItemWithUID:(NSString *)itemUID {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Item"];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:nil];
    
    NSString *predicateStr = [[NSString alloc] initWithFormat:@"uniqueID like %@", itemUID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID like %@", itemUID];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    [_lockForDataModel lock];
    NSArray *result = [_context executeFetchRequest:request error:&err];
    [_lockForDataModel unlock];
    if (!result) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] == 0) {
        return nil;
    } else {
        if ([result count] != 1) {
            NSLog(@"count = %d", [result count]);
//            [NSException raise:@"DCDataModelHelper error" format:@"Reason: The result count for get asset from AtomicArtistModel != 1 count = %d", [result count]];
        }
        
        return [result objectAtIndex:0];
    }
}

- (void)createItemWithUID:(NSString *)itemUID andThumbnail:(UIImage *)thumbnail {
    if ([self getItemWithUID:itemUID] == nil) {
        [_lockForDataModel lock];
        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_context];
        
        item.uniqueID = itemUID;
        item.thumbnail = thumbnail;
        item.thumbnailData = UIImagePNGRepresentation(thumbnail);
        [_lockForDataModel unlock];
    }
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
    [_lockForDataModel lock];
    NSArray *result = [_context executeFetchRequest:request error:&err];
    [_lockForDataModel unlock];
    if (!result) {
        [NSException raise:@"DCDataModelHelper error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] == 0) {
        return nil;
    } else {
        if ([result count] != 1) {
            [NSException raise:@"DCDataModelHelper error" format:@"Reason: The result count for get album from AtomicArtistModel != 1"];
        }
        
        return [result objectAtIndex:0];
    }
}

- (void)createGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    if ([self getGroupWithUID:groupUID] == nil) {
        [_lockForDataModel lock];
        Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
        
        group.uniqueID = groupUID;
        group.posterItemUID = posterItemUID;
        group.posterImage = posterImage;
        group.posterImageData = UIImagePNGRepresentation(posterImage);
        [_lockForDataModel unlock];
    }
}

- (void)updateGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    Group *group = [self getGroupWithUID:groupUID];
    if (group) {
        [_lockForDataModel lock];
        group.posterItemUID = posterItemUID;
        group.posterImage = posterImage;
        group.posterImageData = UIImagePNGRepresentation(posterImage);
        group.inspectionRecord = [NSDate date];
        [_lockForDataModel unlock];
    } else {
        [_lockForDataModel lock];
        group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
        
        group.uniqueID = groupUID;
        group.posterItemUID = posterItemUID;
        group.posterImage = posterImage;
        group.posterImageData = UIImagePNGRepresentation(posterImage);
        [_lockForDataModel unlock];
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
        [staticDefaultDataModelHelper saveChanges];
        [staticDefaultDataModelHelper release];
        staticDefaultDataModelHelper = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultDataModelHelper];
}

- (void)dealloc {
    
    if (_context) {
        [_context release];
        _context = nil;
    }
    
    if (_model) {
        [_model release];
        _model = nil;
    }
    
    if (_lockForDataModel) {
        [_lockForDataModel release];
        _lockForDataModel = nil;
    }
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        if (!_lockForDataModel) {
            _lockForDataModel = [[NSLock alloc] init];
        }
        
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
    [_lockForDataModel lock];
    BOOL successful = [_context save:&err];
    [_lockForDataModel unlock];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}


@end
