//
//  AADataStore.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "AADataStore.h"
#import "Album.h"
#import "Asset.h"

static AADataStore *staticDefaultStore = nil;

@interface AADataStore () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}

@end

@implementation AADataStore

- (Asset *)getAssetWithURL:(NSURL *)assetURL {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Asset"];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString like %@", [assetURL absoluteString]];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"AADataStore error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] != 1) {
        [NSException raise:@"AADataStore error" format:@"Reason: The result count for get asset from CoreData != 1"];
    }
    
    return [result objectAtIndex:0];
}

- (Album *)getAlbumWithURL:(NSURL *)albumURL {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Album"];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString like %@", [albumURL absoluteString]];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"AADataStore error" format:@"Reason: %@", [err localizedDescription]];
    }
    
    if ([result count] != 1) {
        [NSException raise:@"AADataStore error" format:@"Reason: The result count for get album from CoreData != 1"];
    }

    return [result objectAtIndex:0];
}

- (void)createAssetmWithURL:(NSURL *)assetURL andThumbnail:(UIImage *)thumbnail {
    Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:_context];
    
    asset.urlString = [assetURL absoluteString];
    asset.thumbnail = thumbnail;
    asset.thumbnailData = UIImagePNGRepresentation(thumbnail);
}

- (void)createAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage {
    Album *album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:_context];
    
    album.urlString = [albumURL absoluteString];
    album.posterAssetURLString = [posterAssetURL absoluteString];
    album.posterImage = posterImage;
    album.posterImageData = UIImagePNGRepresentation(posterImage);
}

- (void)updateAlbumWithURL:(NSURL *)albumURL posterAssetURL:(NSURL *)posterAssetURL andPosterImage:(UIImage *)posterImage {
    Album *album = [self getAlbumWithURL:albumURL];
    if (album) {
        album.posterAssetURLString = [posterAssetURL absoluteString];
        album.posterImage = posterImage;
        album.posterImageData = UIImagePNGRepresentation(posterImage);
        album.inspectionRecord = [NSDate date];
    } else {
        album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:_context];
        
        album.urlString = [albumURL absoluteString];
        album.posterAssetURLString = [posterAssetURL absoluteString];
        album.posterImage = posterImage;
        album.posterImageData = UIImagePNGRepresentation(posterImage);
    }
}

+ (AADataStore *)defaultStore {
    if (!staticDefaultStore) {
        staticDefaultStore = [[super allocWithZone:nil] init];
    }
    
    return staticDefaultStore;
}

+ (void)staticRelease {
    if (staticDefaultStore) {
        [staticDefaultStore release];
        staticDefaultStore = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultStore];
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
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
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
