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

#define DATAMODELTHREADSTACKSIZE ((NSUInteger)(1024 *1024 * 8))

static DCDataModelHelper *staticDefaultDataModelHelper = nil;

NSString * const ITEM = @"ITEM";
NSString * const ITEM_UID = @"ITEM_UID";
NSString * const ITEM_THUMBNAIL = @"ITEM_THUMBNAIL";
NSString * const GROUP = @"GROUP";
NSString * const GROUP_UID = @"GROUP_UID";
NSString * const GROUP_POSTERIMAGE = @"GROUP_POSTERIMAGE";
NSString * const GROUP_POSTERIMAGEITEMUID = @"GROUP_POSTERIMAGEITEMUID";

@interface DCDataModelHelper () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}

- (void)internlGetItemWithUID:(NSMutableDictionary *)arg;

- (void)internlCreateItemWithUID:(NSMutableDictionary *)arg;

- (void)internlGetGroupWithUID:(NSMutableDictionary *)arg;

- (void)internlCreateGroupWithUID:(NSMutableDictionary *)arg;

- (void)internlUpdateGroupWithUID:(NSMutableDictionary *)arg;

- (void)internlSaveChanges;

@end

@implementation DCDataModelHelper

#pragma mark item
- (void)internlGetItemWithUID:(NSMutableDictionary *)arg {
    do {
        NSString *itemUID = [arg objectForKey:ITEM_UID];
        
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
        
        if ([result count] == 0) {
            ;
        } else {
            if ([result count] != 1) {
                NSLog(@"count = %d", [result count]);
            }
            [arg setObject:[result objectAtIndex:0] forKey:ITEM];
        }
    } while (NO);
}

- (void)internlCreateItemWithUID:(NSMutableDictionary *)arg {
    do {
        NSString *itemUID = [arg objectForKey:ITEM_UID];
        
        UIImage *thumbnail = [arg objectForKey:ITEM_THUMBNAIL];
        
        [self internlGetItemWithUID:arg];
        
        if (![arg objectForKey:ITEM]) {
            Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_context];
            
            item.uniqueID = itemUID;
            item.thumbnail = thumbnail;
            item.thumbnailData = UIImagePNGRepresentation(thumbnail);
        }
    } while (NO);
}

- (Item *)getItemWithUID:(NSString *)itemUID {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:itemUID forKey:ITEM_UID];
//    [self performSelector:@selector(internlGetItemWithUID:) onThread:_thread withObject:arg waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlGetItemWithUID:) withObject:arg waitUntilDone:YES];
    Item *result = [arg objectForKey:ITEM];
    return result;
}

- (void)createItemWithUID:(NSString *)itemUID andThumbnail:(UIImage *)thumbnail {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:itemUID forKey:ITEM_UID];
    [arg setObject:thumbnail forKey:ITEM_THUMBNAIL];
//    [self performSelector:@selector(internlCreateItemWithUID:) onThread:_thread withObject:arg waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlCreateItemWithUID:) withObject:arg waitUntilDone:YES];
}

#pragma mark group
- (void)internlGetGroupWithUID:(NSMutableDictionary *)arg {
    do {
        NSString *groupUID = [arg objectForKey:GROUP_UID];
        
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
        
        if ([result count] == 0) {
            ;
        } else {
            if ([result count] != 1) {
                [NSException raise:@"DCDataModelHelper error" format:@"Reason: The result count for get album from AtomicArtistModel != 1"];
            }
            [arg setObject:[result objectAtIndex:0] forKey:GROUP];
        }
    } while (NO);
    
}

- (void)internlCreateGroupWithUID:(NSMutableDictionary *)arg {
    do {
        NSString *groupUID = [arg objectForKey:GROUP_UID];
        
        UIImage *posterImage = [arg objectForKey:GROUP_POSTERIMAGE];
        
        NSString *posterItemUID = [arg objectForKey:GROUP_POSTERIMAGEITEMUID];
        
        [self internlGetGroupWithUID:arg];
        
        if (![arg objectForKey:GROUP]) {
            Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
            
            group.uniqueID = groupUID;
            group.posterItemUID = posterItemUID;
            group.posterImage = posterImage;
            group.posterImageData = UIImagePNGRepresentation(posterImage);
        }
    } while (NO);
}

- (void)internlUpdateGroupWithUID:(NSMutableDictionary *)arg {
    do {
        NSString *groupUID = [arg objectForKey:GROUP_UID];
        
        UIImage *posterImage = [arg objectForKey:GROUP_POSTERIMAGE];
        
        NSString *posterItemUID = [arg objectForKey:GROUP_POSTERIMAGEITEMUID];
        
        [self internlGetGroupWithUID:arg];
        
        Group *group = [arg objectForKey:GROUP];
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
    } while (NO);
}

- (Group *)getGroupWithUID:(NSString *)groupUID {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
//    [self performSelector:@selector(internlGetGroupWithUID:) onThread:_thread withObject:arg waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlGetGroupWithUID:) withObject:arg waitUntilDone:YES];
    Group *result = [arg objectForKey:GROUP];
    return result;
}

- (void)createGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
    [arg setObject:posterItemUID forKey:GROUP_POSTERIMAGEITEMUID];
    [arg setObject:posterImage forKey:GROUP_POSTERIMAGE];
//    [self performSelector:@selector(internlCreateGroupWithUID:) onThread:_thread withObject:arg waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlCreateGroupWithUID:) withObject:arg waitUntilDone:YES];
}

- (void)updateGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
    [arg setObject:posterItemUID forKey:GROUP_POSTERIMAGEITEMUID];
    [arg setObject:posterImage forKey:GROUP_POSTERIMAGE];
//    [self performSelector:@selector(internlUpdateGroupWithUID:) onThread:_thread withObject:arg waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlUpdateGroupWithUID:) withObject:arg waitUntilDone:YES];
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
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        // Read in AtomicArtistModel.xcdatamodeld
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog(@"model = %@", model);
        
        NSPersistentStoreCoordinator *psc = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model] autorelease];
        
        // Where does the SQLite file go?    
        NSString *path = [DCDataModelHelper archivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path]; 
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            [NSException raise:@"DCDataModelHelper error" format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [_context setUndoManager:nil];
    }
    return self;
}

+ (NSString *)archivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"dataModel.data"];
}

- (void)internlSaveChanges {
    NSError *err = nil;
    BOOL successful = [_context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
}

- (void)saveChanges {
//    [self performSelector:@selector(internlSaveChanges) onThread:_thread withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(internlSaveChanges) withObject:nil waitUntilDone:YES];
}

@end
