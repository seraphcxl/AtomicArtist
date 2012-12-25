//
//  DCMediaDBOperator.m
//  Quartz
//
//  Created by Chen XiaoLiang on 12/25/12.
//  Copyright (c) 2012 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaDBOperator.h"
#import <CoreData/CoreData.h>
#import "Item.h"
#import "Group.h"


#pragma mark - interface DCMediaDBOperator
@interface DCMediaDBOperator () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
    
    NSOperationQueue *_operationQueue;
}

@end


#pragma mark - implementation DCMediaDBOperator
@implementation DCMediaDBOperator

@synthesize threadID = _threadID;

#pragma mark - DCMediaDBOperator - Public method
+ (NSString *)archivePath {
    NSString *result = nil;
    do {
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        // Get one and only document directory from that list
        NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        
        result = [documentDirectory stringByAppendingPathComponent:QUARTZ_DBFILE];
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
            
            @synchronized(_context) {
                // Read in AtomicArtistModel.xcdatamodeld
                _model = [NSManagedObjectModel mergedModelFromBundles:nil];
                // debug_NSLog(@"model = %@", model);
                
                NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
                
                // Where does the SQLite file go?
                NSError *error = nil;
                if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[DCMediaDBOperator archivePath]] options:nil error:&error]) {
                    [NSException raise:@"DCMediaDBOperator error" format:@"Reason: %@", [error localizedDescription]];
                }
                
                // Create the managed object context
                _context = [[NSManagedObjectContext alloc] init];
                [_context setPersistentStoreCoordinator:psc];
                
                // The managed object context can manage undo, but we don't need it
                [_context setUndoManager:nil];
            }
        }
        result = self;
    } while (NO);
    return result;
}

#pragma mark - DCMediaDBOperator - Private method

@end
