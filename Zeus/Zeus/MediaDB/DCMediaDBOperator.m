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
#import "DCMediaDBCommonDefine.h"


#pragma mark - interface DCMediaDBOperator
@interface DCMediaDBOperator () {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}

- (void)mergeContextChanges:(NSNotification *)aNotification;
- (void)mergeOnThread:(NSNotification *)aNotification;

- (void)saveChanges;

@end


#pragma mark - implementation DCMediaDBOperator
@implementation DCMediaDBOperator

@synthesize threadID = _threadID;
@synthesize thread = _thread;

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

- (id)initWithThread:(NSThread *)thread andThreadID:(NSString *)threadID {
    id result = nil;
    do {
        if (!thread || !threadID) {
            break;
        }
        self = [super init];
        if (self) {
            _thread = thread;
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
                [_context setStalenessInterval:0.0];
                [_context setMergePolicy:NSOverwriteMergePolicy];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChanges:) name:NSManagedObjectContextDidSaveNotification object:_context];
                
                SAFE_ARC_SAFERELEASE(psc);
            }
        }
        result = self;
    } while (NO);
    return result;
}

- (void)dealloc {
    do {
        @synchronized(_context) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:_context];
            
            SAFE_ARC_SAFERELEASE(_context);
            SAFE_ARC_SAFERELEASE(_model);
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (Item *)getItemWithUID:(NSString *)itemUID {
    Item *result = nil;
    do {
        if (!itemUID) {
            break;
        }
                
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Item"];
        [request setEntity:entityDescription];
        
        [request setSortDescriptors:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", itemUID];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *resultArray = nil;
        
        @synchronized(_context) {
            resultArray = [_context executeFetchRequest:request error:&error];
        }
        
        if (!resultArray) {
            [NSException raise:@"DCMediaDBOperator error" format:@"Reason: %@", [error localizedDescription]];
        }
        
        if ([resultArray count] == 0) {
            ;
        } else {
            if ([resultArray count] != 1) {
                [NSException raise:@"DCMediaDBOperator error" format:@"Reason: The result count for get item from MeidaDB != 1"];
            }
            result = [resultArray objectAtIndex:0];
        }
        SAFE_ARC_SAFERELEASE(request);

    } while (NO);
    return result;
}

- (void)createItemWithUID:(NSString *)itemUID andArguments:(NSDictionary *)args {
    do {
        if (!itemUID || !args) {
            break;
        }
        @synchronized(_context) {
            Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_context];
            
            item.uniqueID = itemUID;
            item.md5 = [args objectForKey:kITEM_MD5];
            item.smallThumbnail = [args objectForKey:kITEM_SMALLTHUMBNAIL];
            item.largeThumbnail = [args objectForKey:kITEM_LARGETHUMBNAIL];
            item.previewImage = [args objectForKey:kITEM_PREVIEWIMAGE];
            
            [self saveChanges];
        }
    } while (NO);
}

- (Group *)getGroupWithUID:(NSString *)groupUID {
    Group *result = nil;
    do {
        if (!groupUID) {
            break;
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entityDescription = [[_model entitiesByName] objectForKey:@"Group"];
        [request setEntity:entityDescription];
        
        [request setSortDescriptors:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", groupUID];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *resultArray = nil;
        
        @synchronized(_context) {
            resultArray = [_context executeFetchRequest:request error:&error];
        }
        
        if (!resultArray) {
            [NSException raise:@"DCMediaDBOperator error" format:@"Reason: %@", [error localizedDescription]];
        }
        
        if ([resultArray count] == 0) {
            ;
        } else {
            if ([resultArray count] != 1) {
                [NSException raise:@"DCMediaDBOperator error" format:@"Reason: The result count for get group from MeidaDB != 1"];
            }
            result = [resultArray objectAtIndex:0];
        }
        SAFE_ARC_SAFERELEASE(request);
    } while (NO);
    return result;
}

- (void)createGroupWithUID:(NSString *)groupUID andArguments:(NSDictionary *)args {
    do {
        if (!groupUID || !args) {
            break;
        }
        @synchronized(_context) {
            Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_context];
            
            group.uniqueID = groupUID;
            group.posterItemID = [args objectForKey:kGROUP_POSTERIMAGEITEMUID];
            group.smallPosterImage = [args objectForKey:kGROUP_SMALLPOSTERIMAGE];
            group.largePosterImage = [args objectForKey:kGROUP_LARGEPOSTERIMAGE];
            
            [self saveChanges];
        }
    } while (NO);
}

- (void)updateGroupWithUID:(NSString *)groupUID andArguments:(NSDictionary *)args {
    do {
        if (!groupUID || !args) {
            break;
        }
        
        Group *group = [self getGroupWithUID:groupUID];
        if (group) {
            @synchronized(_context) {
                group.posterItemID = [args objectForKey:kGROUP_POSTERIMAGEITEMUID];
                group.smallPosterImage = [args objectForKey:kGROUP_SMALLPOSTERIMAGE];
                group.largePosterImage = [args objectForKey:kGROUP_LARGEPOSTERIMAGE];
                
                [self saveChanges];
            }
        } else {
            [self createGroupWithUID:groupUID andArguments:args];
        }
    } while (NO);
}

#pragma mark - DCMediaDBOperator - Private method
- (void)saveChanges {
    do {
        if (_context) {
            NSError *error = nil;
            BOOL successful = [_context save:&error];
            if (!successful) {
                [NSException raise:@"DCMediaDBOperator error" format:@"Reason: %@", [error localizedDescription]];
            }
        }
    } while (NO);
}

- (void)mergeContextChanges:(NSNotification *)aNotification {
    do {
        if (!aNotification || !self.thread) {
            break;
        }
        if ([NSThread currentThread] == self.thread) {
            [self mergeOnThread:aNotification];
        } else {
            [self performSelector:@selector(mergeOnThread:) onThread:self.thread withObject:aNotification waitUntilDone:YES];
        }
    } while (NO);
}

- (void)mergeOnThread:(NSNotification *)aNotification {
    do {
        if (!aNotification) {
            break;
        }
        @synchronized(_context) {
            if (_context) {
                [_context mergeChangesFromContextDidSaveNotification:aNotification];
            }
        }
    } while (NO);
}

@end
