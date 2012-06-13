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
#import "DCDataModelCommonDefine.h"

#import "DCGetItemOperation.h"
#import "DCCreateItemOperation.h"

#import "DCGetGroupOperation.h"
#import "DCCreateGroupOperation.h"
#import "DCUpdateGroupOperation.h"

#import "DCSaveOperation.h"

#define DATAMODELTHREADSTACKSIZE ((NSUInteger)(1024 *1024 * 8))

static DCDataModelHelper *staticDefaultDataModelHelper = nil;

@interface DCDataModelHelper () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
    
    NSOperationQueue *_operationQueue;
}

@end

@implementation DCDataModelHelper

#pragma mark item

- (Item *)getItemWithUID:(NSString *)itemUID {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:itemUID forKey:ITEM_UID];
    DCGetItemOperation *operation = [[[DCGetItemOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
    Item *result = [arg objectForKey:ITEM];
    return result;
}

- (void)createItemWithUID:(NSString *)itemUID andThumbnail:(UIImage *)thumbnail {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:itemUID forKey:ITEM_UID];
    [arg setObject:thumbnail forKey:ITEM_THUMBNAIL];
    DCGetItemOperation *operation = [[[DCGetItemOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
    Item *result = [arg objectForKey:ITEM];
    if (!result) {
        DCCreateItemOperation *operation1 = [[[DCCreateItemOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
        NSArray *operations1 = [NSArray arrayWithObject:operation1];
        [_operationQueue addOperations:operations1 waitUntilFinished:YES];
    }
}

#pragma mark group
- (Group *)getGroupWithUID:(NSString *)groupUID {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
    DCGetGroupOperation *operation = [[[DCGetGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
    Group *result = [arg objectForKey:GROUP];
    return result;
}

- (void)createGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
    [arg setObject:posterItemUID forKey:GROUP_POSTERIMAGEITEMUID];
    [arg setObject:posterImage forKey:GROUP_POSTERIMAGE];
    DCGetGroupOperation *operation = [[[DCGetGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
    Group *result = [arg objectForKey:GROUP];
    if (!result) {
        DCCreateGroupOperation *operation1 = [[[DCCreateGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
        NSArray *operations1 = [NSArray arrayWithObject:operation1];
        [_operationQueue addOperations:operations1 waitUntilFinished:YES];
    }
}

- (void)updateGroupWithUID:(NSString *)groupUID posterItemUID:(NSString *)posterItemUID andPosterImage:(UIImage *)posterImage {
    NSMutableDictionary *arg = [[[NSMutableDictionary alloc] init] autorelease];
    [arg setObject:groupUID forKey:GROUP_UID];
    [arg setObject:posterItemUID forKey:GROUP_POSTERIMAGEITEMUID];
    [arg setObject:posterImage forKey:GROUP_POSTERIMAGE];
    DCGetGroupOperation *operation = [[[DCGetGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
    Group *result = [arg objectForKey:GROUP];
    if (!result) {
        DCCreateGroupOperation *operation1 = [[[DCCreateGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
        NSArray *operations1 = [NSArray arrayWithObject:operation1];
        [_operationQueue addOperations:operations1 waitUntilFinished:YES];
    } else {
        DCUpdateGroupOperation *operation2 = [[[DCUpdateGroupOperation alloc] initWithConetet:_context model:_model andArgs:arg] autorelease];
        NSArray *operations2 = [NSArray arrayWithObject:operation2];
        [_operationQueue addOperations:operations2 waitUntilFinished:YES];
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
    if (_operationQueue) {
        [_operationQueue release];
        _operationQueue = nil;
    }
    
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
        
        if (!_operationQueue) {
            _operationQueue = [[NSOperationQueue alloc] init];
            [_operationQueue setMaxConcurrentOperationCount:1];
        }
        
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

- (void)saveChanges {
    DCSaveOperation *operation = [[[DCSaveOperation alloc] initWithConetet:_context model:_model andArgs:nil] autorelease];
    NSArray *operations = [NSArray arrayWithObject:operation];
    [_operationQueue addOperations:operations waitUntilFinished:YES];
}

@end
