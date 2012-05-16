//
//  AAItemViewController.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "AAItemViewController.h"
#import "AAAssetLibHelper.h"
#import "AAItemViewCell.h"
#import "AAAssetsGroup.h"
#import "AADetailViewController.h"

@interface AAItemViewController () {
    NSUInteger _itemCountInCell;
    NSUInteger _frameSize;
    NSUInteger _cellSpace;
    
    NSMutableDictionary *_itemViews;
}

- (void)reloadTableView:(NSNotification *)note;

- (void)actionForWillEnterForegroud:(NSNotification *)note;

- (NSUInteger)calcCellSpace;

- (NSUInteger)calcItemCountInCell;

- (NSUInteger)calcFrameSize;

- (void)refreshAssets:(BOOL)force;

- (void)clearCache;

@end

@implementation AAItemViewController

@synthesize groupPersistentID = _groupPersistentID;
@synthesize groupTitle = _groupTitle;

- (void)clearCache {
    if (_itemViews) {
        [_itemViews removeAllObjects];
    }
    
    AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
    [assetLibHelper cleaeCacheForGoupPersistentID:self.groupPersistentID];
}

- (void)addItemView:(AAItemView *)itemView {
    if (itemView && _itemViews) {
        NSURL *assetURL = itemView.assetURL;
        [_itemViews setObject:itemView forKey:assetURL.absoluteString];
    }
}

- (AAItemView *)getItemViewWithAssetURL:(NSURL *)assetURL {
    AAItemView *result = nil;
    do {
        if (_itemViews) {
            result = [_itemViews objectForKey:assetURL.absoluteString];
        }
    } while (NO);
    return result;
}

- (void)actionForWillEnterForegroud:(NSNotification *)note {
    if (self.navigationController.topViewController == self) {
        [self refresh:nil];
    }
}

- (void)dealloc {
    if (_itemViews) {
        [_itemViews removeAllObjects];
        [_itemViews release];
        _itemViews = nil;
    }
    
    self.groupPersistentID = nil;
    
    if (_groupTitle) {
        [_groupTitle release];
        _groupTitle = nil;
    }
    
    [super dealloc];
}

- (IBAction)refresh:(id)sender {
    AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
    ALAssetsGroup *group = [assetLibHelper getALGroupForGoupPersistentID:self.groupPersistentID];
    NSLog(@"groupID:%@ assets count = %d", self.groupPersistentID, [group numberOfAssets]);
    if ([group numberOfAssets] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        NSNotification *note = [NSNotification notificationWithName:@"NotifyRefreshGroup" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    } else {
        [self refreshAssets:YES];
    }
}

- (void)refreshAssets:(BOOL)force {
    NSLog(@"AAItemViewController refreshAssets");
    AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
    if (force || [assetLibHelper assetCountForGroupWithPersistentID:self.groupPersistentID] == 0) {
        [self clearCache];
        [assetLibHelper enumerateAssetsForGoupPersistentID:self.groupPersistentID];
    }
    
    ALAssetsGroup *group = [assetLibHelper getALGroupForGoupPersistentID:self.groupPersistentID];
    if (!group) {
        [NSException raise:@"AAGroupViewController error" format:@"Reason: assetLibHelper getALGroupForGoupPersistentID:%@ error", self.groupPersistentID];
        return;
    }
    NSString *groupPropertyName = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger numberOfAssets = [group numberOfAssets];
    
    _groupTitle = [[[NSString alloc] initWithFormat:@"%@ (%d)", groupPropertyName, numberOfAssets] autorelease];
    [_groupTitle retain];
    
    [self.navigationItem setTitle:self.groupTitle];
}

- (void)selectItem:(NSURL *)assetURL {
    if (assetURL && self.groupPersistentID) {
        AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
        NSUInteger index = [assetLibHelper getIndexInGoupPersistentID:self.groupPersistentID forAssetURL:assetURL];
        AADetailViewController *detailViewCtrl = [[[AADetailViewController alloc] initWithGroupPersistentID:self.groupPersistentID assetURL:assetURL andAssetIndexInGroup:index] autorelease];
        
        [self.navigationController pushViewController:detailViewCtrl animated:YES];
    } else {
        [NSException raise:@"AAItemViewController Error" format:@"Reason: assetURL is nil or self.groupPersistentID is nil"];
    }
}

- (NSArray *)getassetURLsForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
    int maxIdx = MIN((indexPath.row + 1) * _itemCountInCell, [assetLibHelper assetCountForGroupWithPersistentID:self.groupPersistentID]); 
    for (int idx = 0 + indexPath.row * _itemCountInCell; idx < maxIdx; ++idx) {
        [result addObject:[assetLibHelper getAssetURLForGoupPersistentID:self.groupPersistentID atIndex:idx]];
        NSLog(@"Get AssetURLStr: %@ at index: %d", [[assetLibHelper getAssetURLForGoupPersistentID:self.groupPersistentID atIndex:idx] absoluteString], idx);
    }
    return result;
}

- (void)reloadTableView:(NSNotification *)note {
    [self.tableView reloadData];
}

- (NSUInteger)calcFrameSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_SIZE_FRAME_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_SIZE_FRAME_IPAD;
    } else {
        [NSException raise:@"AAItemViewController error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSUInteger)calcItemCountInCell {
    if (_frameSize == 0) {
        [NSException raise:@"AAItemViewController error" format:@"Reason: frameSize == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return (NSUInteger)(bounds.size.width / _frameSize);
}

- (NSUInteger)calcCellSpace {
    if (_frameSize == 0) {
        [NSException raise:@"AAItemViewController error" format:@"Reason: frameSize == 0"];
    }
    if (_itemCountInCell == 0) {
        [NSException raise:@"AAItemViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return (NSUInteger)((bounds.size.width - _itemCountInCell * _frameSize) / (_itemCountInCell + 1));
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        frameSize = [self calcFrameSize];
//        itemCountInCell = [self calcItemCountInCell];
//        cellSpace = [self calcCellSpace];
        
        if (!_itemViews) {
            _itemViews = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"AAItemViewController viewDidLoad:");
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];
//    [self.tableView setAlpha:0.6];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setAllowsSelection:NO];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(reloadTableView:) name:@"ALAssetAdded" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForWillEnterForegroud:) name:@"applicationWillEnterForeground:" object:nil];
    
    UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    [self.navigationItem setRightBarButtonItem:bbi];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"AAItemViewController viewWillAppear:");
    [super viewWillAppear:animated];
    
    _frameSize = [self calcFrameSize];
    _itemCountInCell = [self calcItemCountInCell];
    _cellSpace = [self calcCellSpace];
    
    if (_itemViews) {
        [_itemViews removeAllObjects];
    }
    
    [self refreshAssets:NO];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"AAItemViewController viewWillDisappear:");
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"AAItemViewController viewDidUnload:");
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self clearCache];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"AAItemViewController shouldAutorotateToInterfaceOrientation:");
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"AAItemViewController error" format:@"Reason: Current device type unknown"];
    }
    
    _frameSize = [self calcFrameSize];
    _itemCountInCell = [self calcItemCountInCell];
    _cellSpace = [self calcCellSpace];
    
    if (_itemViews) {
        [_itemViews removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    return result;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"AAItemViewController numberOfSectionsInTableView:");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"AAItemViewController tableView:numberOfRowsInSection:");
    // Return the number of rows in the section.
    AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
    
    if (_itemCountInCell == 0) {
        [NSException raise:@"AAItemViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    NSInteger assetCount = [assetLibHelper assetCountForGroupWithPersistentID:self.groupPersistentID];
    NSLog(@"assetCount = %d", assetCount);
    NSInteger addLine = 0;
    if (assetCount % _itemCountInCell != 0) {
        addLine = 1;
    }
    return assetCount / _itemCountInCell + addLine;
    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"AAItemViewController tableView:cellForRowAtIndexPath:");
    AAItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AAItemViewCell"];
    if (cell == nil) {
        cell = [[[AAItemViewCell alloc] initWithAssetURLs:[self getassetURLsForCellAtIndexPath:indexPath] groupPersistentID:self.groupPersistentID cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) frameSize:_frameSize andItemCount:_itemCountInCell] autorelease];
    } else {
        [cell initWithAssetURLs:[self getassetURLsForCellAtIndexPath:indexPath] groupPersistentID:self.groupPersistentID cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) frameSize:_frameSize andItemCount:_itemCountInCell];
    }
    cell.delegate = self;
    cell.delegateForItemView = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (_frameSize + _cellSpace);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
