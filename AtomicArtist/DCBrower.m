//
//  DCBrower.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCBrower.h"
#import "DCALAssetGroupViewController.h"
#import "DCALAssetsLibraryHelper.h"
#import "DCDataLoader.h"

@implementation DCBrower

@synthesize naviCtrl = _naviCtrl;
@synthesize type = _type;

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5.0) {
        [viewController viewWillAppear:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5.0) {
        [viewController viewDidAppear:animated];
    }
}

- (id)init:(enum GROUPVIEWCTRL_TYPE)type {
    self = [self init];
    if (self) {
        _type = type;
        
        UIViewController *viewCtrl = nil;
        if (self.type == GROUPVIEWCTRL_TYPE_ALASSET) {
            DCALAssetsLibraryHelper *alAssetsLibraryHelper = [DCALAssetsLibraryHelper defaultDataLibraryHelper];
            [alAssetsLibraryHelper connect:nil];
            DCALAssetGroupViewController *groupViewCtrl = [[[DCALAssetGroupViewController alloc] initWithDataLibHelper:alAssetsLibraryHelper] autorelease];
            [groupViewCtrl setEnumDataGroupParam:(id)(ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos)];
            [groupViewCtrl setEnumDataItemParam:(id)ALAssetTypePhoto];
            
            viewCtrl = groupViewCtrl;
        }
        
        if (!_naviCtrl) {
            _naviCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        }
        
        [self.naviCtrl setDelegate:self];
        [self.naviCtrl.view setBackgroundColor:[UIColor blackColor]];
        [self.naviCtrl.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        
        
    }
    return self;
}

- (void)dealloc {
    if (_naviCtrl) {
        [_naviCtrl release];
        _naviCtrl = nil;
    }
    
    if (self.type == GROUPVIEWCTRL_TYPE_ALASSET) {
        DCALAssetsLibraryHelper *alAssetsLibraryHelper = [DCALAssetsLibraryHelper defaultDataLibraryHelper];
        [alAssetsLibraryHelper disconnect];
    }
    
    [super dealloc];
}

@end
