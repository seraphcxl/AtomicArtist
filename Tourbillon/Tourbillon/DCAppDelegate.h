//
//  DCAppDelegate.h
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12-12-4.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
