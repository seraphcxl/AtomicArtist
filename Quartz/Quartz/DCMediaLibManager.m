//
//  DCMediaLibManager.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaLibManager.h"
#import <CoreData/CoreData.h>
#import "Item.h"
#import "Group.h"


#pragma mark - interface DCMediaLibManager
@interface DCMediaLibManager () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
    
    NSOperationQueue *_operationQueue;
}

@end


#pragma mark - implementation DCMediaLibManager
@implementation DCMediaLibManager

@synthesize threadID = _threadID;

#pragma mark - DCMediaLibManager - Public method
+ (NSString *)archivePath {
    NSString *result = nil;
    do {
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        // Get one and only document directory from that list
        NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        
        result = [documentDirectory stringByAppendingPathComponent:@"MediaLib.data"];
    } while (NO);
    return result;
}

- (id)initWithThreadID:(NSString *)threadID {
    id result = nil;
    do {
        if (!threadID) {
            break;
        }
        self = [super init];
        if (self) {
            _threadID = [threadID copy];
            
            // Read in AtomicArtistModel.xcdatamodeld
            _model = [NSManagedObjectModel mergedModelFromBundles:nil];
            // debug_NSLog(@"model = %@", model);
            
            NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
            
            // Where does the SQLite file go?
            NSError *error = nil;
            if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[DCMediaLibManager archivePath]] options:nil error:&error]) {
                [NSException raise:@"MediaLibManger error" format:@"Reason: %@", [error localizedDescription]];
            }
            
            // Create the managed object context
            _context = [[NSManagedObjectContext alloc] init];
            [_context setPersistentStoreCoordinator:psc];
            
            // The managed object context can manage undo, but we don't need it
            [_context setUndoManager:nil];
        }
        result = self;
    } while (NO);
    return result;
}

#pragma mark - DCMediaLibManager - Private method

@end
