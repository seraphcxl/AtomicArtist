//
//  DCGroupViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupViewController.h"
#import "DCItemViewController.h"

@interface DCGroupViewController () {
    NSUInteger _itemCountInCell;
    NSUInteger _frameSize;
    NSUInteger _cellSpace;
    
    NSMutableDictionary *_groupViews;
}

- (void)reloadTableView:(NSNotification *)note;

- (void)notifyRefresh:(NSNotification *)note;

- (void)actionForWillEnterForegroud:(NSNotification *)note;

- (NSUInteger)calcCellSpace;

- (NSUInteger)calcItemCountInCell;

- (NSUInteger)calcFrameSize;

- (NSArray *)dataGroupUIDsForCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)refreshGroups:(BOOL)force;

- (void)clearCache;

- (NSString *)title;

@end

@interface DCGroupViewController ()

@end

@implementation DCGroupViewController

@synthesize dataLibraryHelper = _dataLibraryHelper;
//@synthesize interfaceOrientation = _interfaceOrientation;

- (void)setEnumDataGroupParam:(id)enumDataGroupParam {
    NSLog(@"need override");
}

- (void)setEnumDataItemParam:(id)enumDataItemParam {
    NSLog(@"need override");
}

- (id)initWithDataLibHelper:(id<DCDataLibraryHelper>)dataLibraryHelper {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.dataLibraryHelper = dataLibraryHelper;
        
        _frameSize = [self calcFrameSize];
        _itemCountInCell = [self calcItemCountInCell];
        _cellSpace = [self calcCellSpace];
        
        if (!_groupViews) {
            _groupViews = [[NSMutableDictionary alloc] init];
        }
        
        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
        [self.navigationItem setRightBarButtonItem:bbi];
    }
    return self;
}

- (void)dealloc {
    [self clearCache];
    
    if (_groupViews) {
        [_groupViews release];
        _groupViews = nil;
    }
    
    self.dataLibraryHelper = nil;
    
    [super dealloc];
}

- (void)clearCache {
    if (_groupViews) {
        [_groupViews removeAllObjects];
    }
    [self.dataLibraryHelper clearCache];
}

- (void)addGroupView:(DCGroupView *)groupView {
    if (groupView && _groupViews) {
        [_groupViews setObject:groupView forKey:groupView.dataGroupUID];
    }
}

- (DCGroupView *)getGroupViewWithDataGroupUID:(NSString *)uid {
    DCGroupView *result = nil;
    do {
        if (_groupViews) {
            result = [_groupViews objectForKey:uid];
        }
    } while (NO);
    return result;
}

- (void)actionForWillEnterForegroud:(NSNotification *)note {
    if (self.navigationController.topViewController == self) {
        [self refreshGroups:YES];
    }
}

- (void)notifyRefresh:(NSNotification *)note {
    [self refreshGroups:YES];
}

- (IBAction)refresh:(id)sender {
    [self refreshGroups:YES];
}

- (void)refreshGroups:(BOOL)force {
    NSLog(@"DCGroupViewController refreshAssetsGroups");
    if (force || [self.dataLibraryHelper groupsCount] == 0) {
        [self clearCache];
        [self.dataLibraryHelper enumGroups:_enumDataGroupParam];
        [self.navigationItem setTitle:[self title]];
    }
}

- (void)selectGroup:(NSString *)dataGroupUID {
    if (dataGroupUID) {
        DCItemViewController *itemViewController = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
        itemViewController.dataGroupUID = dataGroupUID;
        itemViewController.enumDataItemParam = _enumDataItemParam;
        [self.navigationController pushViewController:itemViewController animated:YES];
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: dataGroupUID == nil"];
    }
}

- (NSArray *)dataGroupUIDsForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    if (self.dataLibraryHelper) {
        int maxIdx = MIN((indexPath.row + 1) * _itemCountInCell, [self.dataLibraryHelper groupsCount]); 
        for (int idx = 0 + indexPath.row * _itemCountInCell; idx < maxIdx; ++idx) {
            [result addObject:[self.dataLibraryHelper groupUIDAtIndex:idx]];
            NSLog(@"Get DataGoupUID: %@ at index: %d", [self.dataLibraryHelper groupUIDAtIndex:idx], idx);
        }
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
    
    return result;
}

- (NSString *)title {
    // this funcation should override by 
    return [[[NSString alloc] initWithFormat:@"Photos"] autorelease];
}

- (NSUInteger)calcFrameSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return GROUPVIEW_SIZE_FRAME_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return GROUPVIEW_SIZE_FRAME_IPAD;
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSUInteger)calcItemCountInCell {
    if (_frameSize == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: frameSize == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return (NSUInteger)(bounds.size.width / _frameSize);
}

- (NSUInteger)calcCellSpace {
    if (_frameSize == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: frameSize == 0"];
    }
    if (_itemCountInCell == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return (NSUInteger)((bounds.size.width - _itemCountInCell * _frameSize) / (_itemCountInCell + 1));
}

- (void)reloadTableView:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    NSLog(@"DCGroupViewController viewDidLoad:");
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*** *** ***/
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setAllowsSelection:NO];
    
    _frameSize = [self calcFrameSize];
    _itemCountInCell = [self calcItemCountInCell];
    _cellSpace = [self calcCellSpace];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(reloadTableView:) name:@"ALGroupAdded" object:nil];
    [notificationCenter addObserver:self selector:@selector(notifyRefresh:) name:@"NotifyRefreshGroup" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForWillEnterForegroud:) name:@"applicationWillEnterForeground:" object:nil];
    /*** *** ***/
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"DCGroupViewController viewWillAppear:");
    [super viewWillAppear:animated];
    
    if (_groupViews) {
        [_groupViews removeAllObjects];
    }
    
    [self refreshGroups:NO];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"DCGroupViewController viewWillDisappear:");
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"DCGroupViewController viewDidUnload:");
    /*** *** ***/
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self clearCache];
    
    /*** *** ***/
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"DCGroupViewController shouldAutorotateToInterfaceOrientation:");
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: Current device type unknown"];
    }
    
    _frameSize = [self calcFrameSize];
    _itemCountInCell = [self calcItemCountInCell];
    _cellSpace = [self calcCellSpace];
    
    if (_groupViews) {
        [_groupViews removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    return result;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"DCGroupViewController numberOfSectionsInTableView:");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"DCGroupViewController tableView:numberOfRowsInSection:");
    // Return the number of rows in the section.
    
    if (_itemCountInCell == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    if (self.dataLibraryHelper) {
        NSInteger dataGroupCount = [self.dataLibraryHelper groupsCount];
        NSLog(@"dataGroupCount = %d", dataGroupCount);
        NSInteger addLine = 0;
        if (dataGroupCount % _itemCountInCell != 0) {
            addLine = 1;
        }
        return dataGroupCount / _itemCountInCell + addLine;
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DCGroupViewController tableView:cellForRowAtIndexPath: indexPath.row = %d", [indexPath row]);
    NSArray *dataGroupUIDs = [self dataGroupUIDsForCellAtIndexPath:indexPath];
    DCGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCGroupViewCell"];
    if (cell == nil) {
        cell = [[[DCGroupViewCell alloc] initWithDataLibHelper:self.dataLibraryHelper dataGroupUIDs:dataGroupUIDs enumDataItemParam:_enumDataItemParam cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) frameSize:_frameSize andItemCount:_itemCountInCell] autorelease];
    } else {
        [cell initWithDataLibHelper:self.dataLibraryHelper dataGroupUIDs:dataGroupUIDs enumDataItemParam:_enumDataItemParam cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) frameSize:_frameSize andItemCount:_itemCountInCell];
    }
    cell.delegate = self;
    cell.delegateForGroupView = self;
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
