//
//  DCItemViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCItemViewController.h"
#import "DCItemViewCell.h"
#import "DCDetailViewController.h"

@interface DCItemViewController () {
    NSUInteger _itemCountInCell;
    NSUInteger _frameSize;
    double _cellSpace;
    NSUInteger _tableViewMargin;
    
    NSMutableDictionary *_itemViews;
}

- (void)reloadTableView:(NSNotification *)note;

- (void)actionForWillEnterForegroud:(NSNotification *)note;

- (double)calcCellSpaceWithFrameSize:(NSUInteger)frameSize tableViewMargin:(NSUInteger)tableViewMargin andItemCountInCell:(NSUInteger)itemCountInCell;

- (NSUInteger)calcItemCountInCellWithFrameSize:(NSUInteger)frameSize andTableViewMargin:(NSUInteger)tableViewMargin;

- (NSUInteger)calcFrameSize;

- (NSUInteger)calcTableViewMargin;

- (void)refreshItems:(BOOL)force;

- (void)clearCache;

- (NSArray *)getItemUIDsForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DCItemViewController

@synthesize delegate = _delegate;
@synthesize delegateForItemView = _delegateForItemView;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize groupTitle = _groupTitle;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize enumDataItemParam = _enumDataItemParam;
@synthesize dataGroupIndex = _dataGroupIndex;

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doNextActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl nextViewCtrl:(UIViewController *)nextViewCtrl {
    NSLog(@"DCItemViewController pageScrollViewCtrl:doNextActionWithCurrentViewCtrl:nextViewCtrl:");
    DCDetailViewController *currentDetailViewCtrl = (DCDetailViewController *)nextViewCtrl;
    [currentDetailViewCtrl retain];
    DCDetailViewController *prevDetailViewCtrl = (DCDetailViewController *)currentViewCtrl;
    [prevDetailViewCtrl retain];
    DCDetailViewController *nextDetailViewCtrl = nil;
    if (currentDetailViewCtrl.currentIndexInGroup == ([self.dataLibraryHelper itemsCountInGroup:self.dataGroupUID] - 1)) {
        ;
    } else {
        NSUInteger nextIndex = currentDetailViewCtrl.currentIndexInGroup + 1;
        NSString *nextItemUID = [self.dataLibraryHelper itemUIDAtIndex:nextIndex inGroup:self.dataGroupUID];
        nextDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:nextItemUID andIndexInGroup:nextIndex] autorelease];
        [nextDetailViewCtrl setDelegate:pageScrollViewCtrl];
        
        [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
        
        [currentDetailViewCtrl release];
        currentDetailViewCtrl = nil;
        [prevDetailViewCtrl release];
        prevDetailViewCtrl = nil;
        
        [pageScrollViewCtrl reloadPageViews];
        [pageScrollViewCtrl scrollToCurrentPageView];
    }
}

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doPreviousActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl previousViewCtrl:(UIViewController *)previousViewCtrl {
    NSLog(@"DCItemViewController pageScrollViewCtrl:doPreviousActionWithCurrentViewCtrl:previousViewCtrl:");
    DCDetailViewController *currentDetailViewCtrl = (DCDetailViewController *)previousViewCtrl;
    [currentDetailViewCtrl retain];
    DCDetailViewController *prevDetailViewCtrl = nil;
    DCDetailViewController *nextDetailViewCtrl = (DCDetailViewController *)currentViewCtrl;
    [nextDetailViewCtrl retain];
    if (currentDetailViewCtrl.currentIndexInGroup == 0) {
        ;
    } else {
        NSUInteger prevIndex = currentDetailViewCtrl.currentIndexInGroup - 1;
        NSString *prevItemUID = [self.dataLibraryHelper itemUIDAtIndex:prevIndex inGroup:self.dataGroupUID];
        prevDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:prevItemUID andIndexInGroup:prevIndex] autorelease];
        [prevDetailViewCtrl setDelegate:pageScrollViewCtrl];
        
        [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
        
        [currentDetailViewCtrl release];
        currentDetailViewCtrl = nil;
        [nextDetailViewCtrl release];
        nextDetailViewCtrl = nil;
        
        [pageScrollViewCtrl reloadPageViews];
        [pageScrollViewCtrl scrollToCurrentPageView];
    }
}

- (void)clearCache {
    if (_itemViews) {
        [_itemViews removeAllObjects];
    }
    
    if (self.dataLibraryHelper) {
        [self.dataLibraryHelper clearCacheInGroup:self.dataGroupUID];
    }
}

- (void)addItemView:(DCItemView *)itemView {
    if (itemView && _itemViews) {
        NSString *itemUID = itemView.itemUID;
        [_itemViews setObject:itemView forKey:itemUID];
    }
}

- (DCItemView *)getItemViewWithItemUID:(NSString *)itemUID {
    DCItemView *result = nil;
    do {
        if (_itemViews) {
            result = [_itemViews objectForKey:itemUID];
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
    
    self.dataGroupUID = nil;
    self.enumDataItemParam = nil;
    
    if (_groupTitle) {
        [_groupTitle release];
        _groupTitle = nil;
    }
    
    [super dealloc];
}

- (IBAction)refresh:(id)sender {
    if (self.dataLibraryHelper) {
        id <DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
        NSLog(@"groupID:%@ items count = %d", self.dataGroupUID, [group itemsCount]);
        if ([group itemsCount] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            NSNotification *note = [NSNotification notificationWithName:@"NotifyRefreshGroup" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        } else {
            [self refreshItems:YES];
        }
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
}

- (void)refreshItems:(BOOL)force {
    NSLog(@"DCItemViewController refreshAssets");
    if (self.dataLibraryHelper) {
        if (force || ![self.dataLibraryHelper isGroupEnumerated:self.dataGroupUID]) {
            [self clearCache];
            [self.dataLibraryHelper enumItems:self.enumDataItemParam InGroup:self.dataGroupUID];
        }
        
        id <DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
        if (!group) {
            [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper groupWithUID:%@ error", self.dataGroupUID];
            return;
        }
        NSString *groupName = [group valueForProperty:kDATAGROUPPROPERTY_GROUPNAME withOptions:nil];
        NSInteger numberOfItems = [group itemsCount];
        
        _groupTitle = [[[NSString alloc] initWithFormat:@"%@ (%d)", groupName, numberOfItems] autorelease];
        [_groupTitle retain];
        
        if (self.delegate) {
            [self.delegate itemViewCtrl:self setGroupTitle:self.groupTitle];
        }
    }
}

- (void)selectItem:(NSString *)itemUID showInPageScrollViewController:(DCPageScrollViewController *)pageScrollViewCtrl {
    if (itemUID && pageScrollViewCtrl && self.dataGroupUID && self.dataLibraryHelper) {
        DCDetailViewController *currentDetailViewCtrl = nil;
        DCDetailViewController *prevDetailViewCtrl = nil;
        DCDetailViewController *nextDetailViewCtrl = nil;
        
        NSUInteger currentIndex = [self.dataLibraryHelper indexForItemUID:itemUID inGroup:self.dataGroupUID];
        currentDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:itemUID andIndexInGroup:currentIndex] autorelease];
        [currentDetailViewCtrl setDelegate:pageScrollViewCtrl];
        
        if (currentIndex != 0) {
            NSUInteger prevIndex = currentIndex - 1;
            NSString *prevItemUID = [self.dataLibraryHelper itemUIDAtIndex:prevIndex inGroup:self.dataGroupUID];
            prevDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:prevItemUID andIndexInGroup:prevIndex] autorelease];
            [prevDetailViewCtrl setDelegate:pageScrollViewCtrl];
        }
        
        if (currentIndex < [self.dataLibraryHelper itemsCountInGroup:self.dataGroupUID] - 1) {
            NSUInteger nextIndex = currentIndex + 1;
            NSString *nextItemUID = [self.dataLibraryHelper itemUIDAtIndex:nextIndex inGroup:self.dataGroupUID];
            nextDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:nextItemUID andIndexInGroup:nextIndex] autorelease];
            [nextDetailViewCtrl setDelegate:pageScrollViewCtrl];
        }
        
        [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
        [pageScrollViewCtrl setDelegate:self];
        [pageScrollViewCtrl setScrollEnabled:YES];
        [pageScrollViewCtrl setHideNavigationBarEnabled:YES];
    } else {
        [NSException raise:@"DCItemViewController Error" format:@"Reason: assetURL is nil or self.groupPersistentID is nil or self.dataLibraryHelper is nil or pageScrollViewCtrl is nil"];
    }
}

- (NSArray *)getItemUIDsForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    if (self.dataLibraryHelper) {
        int maxIdx = MIN((indexPath.row + 1) * _itemCountInCell, [self.dataLibraryHelper itemsCountInGroup:self.dataGroupUID]); 
        for (int idx = 0 + indexPath.row * _itemCountInCell; idx < maxIdx; ++idx) {
            [result addObject:[self.dataLibraryHelper itemUIDAtIndex:idx inGroup:self.dataGroupUID]];
            NSLog(@"Get itemUID: %@ at index: %d", [self.dataLibraryHelper itemUIDAtIndex:idx inGroup:self.dataGroupUID], idx);
        }
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
        [NSException raise:@"DCItemViewController error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSUInteger)calcTableViewMargin {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_TABLEVIEW_MARGIN_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_TABLEVIEW_MARGIN_IPAD;
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSUInteger)calcItemCountInCellWithFrameSize:(NSUInteger)frameSize andTableViewMargin:(NSUInteger)tableViewMargin {
    if (frameSize == 0) {
        [NSException raise:@"DCItemViewController error" format:@"Reason: frameSize == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    if ((NSUInteger)(bounds.size.width - (tableViewMargin * 2)) % (NSUInteger)frameSize < (frameSize / 4)) {
        return (NSUInteger)(((bounds.size.width - (tableViewMargin * 2)) / frameSize) - 1);
    } else {
        return (NSUInteger)((bounds.size.width - (tableViewMargin * 2)) / frameSize);
    }
    
}

- (double)calcCellSpaceWithFrameSize:(NSUInteger)frameSize tableViewMargin:(NSUInteger)tableViewMargin andItemCountInCell:(NSUInteger)itemCountInCell {
    if (frameSize == 0) {
        [NSException raise:@"DCItemViewController error" format:@"Reason: frameSize == 0"];
    }
    if (itemCountInCell == 0) {
        [NSException raise:@"DCItemViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return ((bounds.size.width - (tableViewMargin * 2) - (itemCountInCell * frameSize)) * 1.0 / (itemCountInCell - 1));
}

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        
        self.dataLibraryHelper = dataLibraryHelper;
        
        if (!_itemViews) {
            _itemViews = [[NSMutableDictionary alloc] init];
        }
        
//        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
//        [self.navigationItem setRightBarButtonItem:bbi];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"DCItemViewController viewDidLoad:");
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setAllowsSelection:NO];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(reloadTableView:) name:@"ALAssetAdded" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForWillEnterForegroud:) name:@"applicationWillEnterForeground:" object:nil];
    
    [self refreshItems:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"DCItemViewController viewWillAppear:");
    [super viewWillAppear:animated];
    
    _frameSize = [self calcFrameSize];
    _tableViewMargin = [self calcTableViewMargin];
    _itemCountInCell = [self calcItemCountInCellWithFrameSize:_frameSize andTableViewMargin:_tableViewMargin];
    _cellSpace = [self calcCellSpaceWithFrameSize:_frameSize tableViewMargin:_tableViewMargin andItemCountInCell:_itemCountInCell];
    
    if (_itemViews) {
        [_itemViews removeAllObjects];
    }
    
    [self refreshItems:NO];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"DCItemViewController viewWillDisappear:");
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"DCItemViewController viewDidUnload:");
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self clearCache];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"DCItemViewController shouldAutorotateToInterfaceOrientation:");
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result = YES;
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: Current device type unknown"];
    }
    
    NSUInteger tmpFrameSize = [self calcFrameSize];
    NSUInteger tmpTableViewMargin = [self calcTableViewMargin];
    NSUInteger tmpItemCountInCell = [self calcItemCountInCellWithFrameSize:tmpFrameSize andTableViewMargin:tmpTableViewMargin];
    double tmpCellSpace = [self calcCellSpaceWithFrameSize:tmpFrameSize tableViewMargin:tmpTableViewMargin andItemCountInCell:tmpItemCountInCell];
    
    if (_frameSize != tmpFrameSize || _tableViewMargin != tmpTableViewMargin || _itemCountInCell != tmpItemCountInCell || _cellSpace != tmpCellSpace) {
        _frameSize = tmpFrameSize;
        _tableViewMargin = tmpTableViewMargin;
        _itemCountInCell = tmpItemCountInCell;
        _cellSpace = tmpCellSpace;
        
        if (_itemViews) {
            [_itemViews removeAllObjects];
        }
        
        [self.tableView reloadData];
    }
    return result;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"DCItemViewController numberOfSectionsInTableView:");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"DCItemViewController tableView:numberOfRowsInSection:");
    // Return the number of rows in the section.
    if (_itemCountInCell == 0) {
        return 0;
    }
    
    if (self.dataLibraryHelper) {
        NSInteger itemsCount = [self.dataLibraryHelper itemsCountInGroup:self.dataGroupUID];
        NSLog(@"itemsCount = %d", itemsCount);
        NSInteger addLine = 0;
        if (itemsCount % _itemCountInCell != 0) {
            addLine = 1;
        }
        return itemsCount / _itemCountInCell + addLine;
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"DCItemViewController tableView:cellForRowAtIndexPath:");
    DCItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AAItemViewCell"];
    NSArray *itemUIDs = [self getItemUIDsForCellAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[DCItemViewCell alloc] initWithDataLibraryHelper:self.dataLibraryHelper itemUIDs:itemUIDs dataGroupUID:self.dataGroupUID cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell] autorelease];
    } else {
        [cell initWithDataLibraryHelper:self.dataLibraryHelper itemUIDs:itemUIDs dataGroupUID:self.dataGroupUID cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell];
    }
    cell.delegate = self;
    cell.delegateForItemView = self.delegateForItemView;
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
