//
//  DCALAssetGroupViewController.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/17/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "DCALAssetGroupViewController.h"

@interface DCALAssetGroupViewController () {
}

- (void)actionForGroupEmpty:(NSNotification *)note;

@end

@implementation DCALAssetGroupViewController

@synthesize sourceSwitch;

- (void)actionForGroupEmpty:(NSNotification *)note {
    if (_enumDataGroupParam == (id)(ALAssetsGroupPhotoStream)) {
        NSLog(@"PhotoStream is empty");
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Photo Stream not available!" message:@"Pls sign in your iCloud accout and enable Photo Stream." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}

- (void)sourceSwitchValueChanged:(id)sender {
    if (self.sourceSwitch) {
        NSLog(@"Select index is %d", self.sourceSwitch.selectedSegmentIndex);
        if (self.sourceSwitch.selectedSegmentIndex == 0) {
            [self setEnumDataGroupParam:(id)(ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos)];
        } else {
            [self setEnumDataGroupParam:(id)(ALAssetsGroupPhotoStream)];
        }
        [self refresh:nil];
    }
}

- (void)setEnumDataGroupParam:(id)enumDataGroupParam {
    _enumDataGroupParam = enumDataGroupParam;
}

- (void)setEnumDataItemParam:(id)enumDataItemParam {
    _enumDataItemParam = enumDataItemParam;
}

- (void)dealloc {
    [sourceSwitch release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSBundle mainBundle] loadNibNamed:@"DCALAssetGroupViewNaviTitle" owner:self options:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitleView:self.sourceSwitch];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(actionForGroupEmpty:) name:NOTIFY_DATAGROUP_EMPTY object:nil];
}

- (void)viewDidUnload
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self setSourceSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
