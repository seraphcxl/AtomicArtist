//
//  DCAppDelegate.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCAppDelegate.h"
//#import "DCALAssetGroupViewController.h"
#import "DCDataModelHelper.h"
#import "DCALAssetsLibraryHelper.h"
#import "DCBrower.h"

@interface DCAppDelegate () {
    DCBrower *_brower;
}

@end

@implementation DCAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor clearColor];
    /*** *** ***/
    if (_brower) {
        [_brower release];
        _brower = nil;
    }
    _brower = [[DCBrower alloc] init:GROUPVIEWCTRL_TYPE_ALASSET];
    [[self window] setRootViewController:_brower.naviCtrl];
    /*** *** ***/
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DCDataModelHelper defaultDataModelHelper] saveChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[DCDataModelHelper defaultDataModelHelper] saveChanges];
    [DCDataModelHelper staticRelease];
    [DCALAssetsLibraryHelper staticRelease];
    
    if (_brower) {
        [_brower release];
        _brower = nil;
    }
}

@end
