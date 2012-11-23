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
#import "DCLoadThumbnailOperation.h"
#import "DCDataModelHelper.h"
#import "DCDataLoader.h"

@interface DCItemViewController () {
    NSUInteger _itemCountInCell;
    NSUInteger _frameSize;
    double _cellSpace;
    NSUInteger _tableViewMargin;
    
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    CGFloat _pinchScale;
}

- (void)reloadTableView:(NSNotification *)note;
- (void)dataRefreshFinished:(NSNotification *)note;
- (void)actionForWillEnterForegroud:(NSNotification *)note;
- (void)actionForItemThumbnailLoaded:(NSNotification *)note;

- (double)calcCellSpaceWithFrameSize:(NSUInteger)frameSize tableViewMargin:(NSUInteger)tableViewMargin andItemCountInCell:(NSUInteger)itemCountInCell;

- (NSUInteger)calcItemCountInCellWithFrameSize:(NSUInteger)frameSize andTableViewMargin:(NSUInteger)tableViewMargin;

- (NSUInteger)calcFrameSize;

- (NSUInteger)calcTableViewMargin;

- (NSUInteger)calcVisiableRowNumber;

- (void)refreshItems:(BOOL)force;
- (void)refreshFirstScreen;
- (void)refreshItemViewTitle;
- (void)clearCache;

- (NSString *)pathInDocumentDirectory:(NSString *)fileName;

- (void)pinch:(UIPinchGestureRecognizer *)gr;

- (void)enumAllItems;
- (void)forceEnumAllItems;

@end

@implementation DCItemViewController

@synthesize delegate = _delegate;
@synthesize delegateForItemView = _delegateForItemView;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize groupTitle = _groupTitle;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize enumDataItemParam = _enumDataItemParam;
@synthesize dataGroupIndex = _dataGroupIndex;
@synthesize viewCache = _viewCache;

- (void)enumAllItems {
    [self refreshItems:NO];
}

- (void)forceEnumAllItems {
    [self refreshItems:YES];
}

- (void)pinch:(UIPinchGestureRecognizer *)gr {
    debug_NSLog(@"DCItemViewController pinch:");
    if (gr.state == UIGestureRecognizerStateBegan) {
        _pinchScale = gr.scale;
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        if (gr.scale < _pinchScale) {
            if (self.delegate) {
                [self.delegate popFormNavigationCtrl];
            }
        }
        _pinchScale = 0.0;
    }
}

- (NSString *)pathInDocumentDirectory:(NSString *)fileName {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doNextActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl nextViewCtrl:(UIViewController *)nextViewCtrl {
    debug_NSLog(@"DCItemViewController pageScrollViewCtrl:doNextActionWithCurrentViewCtrl:nextViewCtrl:");
    DCDetailViewController *currentDetailViewCtrl = (DCDetailViewController *)nextViewCtrl;
    [currentDetailViewCtrl retain];
    DCDetailViewController *prevDetailViewCtrl = (DCDetailViewController *)currentViewCtrl;
    [prevDetailViewCtrl retain];
    DCDetailViewController *nextDetailViewCtrl = nil;
    if (currentDetailViewCtrl.currentIndexInGroup == ([self.dataLibraryHelper enumratedItemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID] - 1)) {
        ;
    } else {
        NSUInteger nextIndex = currentDetailViewCtrl.currentIndexInGroup + 1;
        NSString *nextItemUID = [self.dataLibraryHelper itemUIDAtIndex:nextIndex inGroup:self.dataGroupUID];
        nextDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:nextItemUID andIndexInGroup:nextIndex] autorelease];
        [nextDetailViewCtrl setDelegate:pageScrollViewCtrl];
    }
    [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
    [pageScrollViewCtrl setDelegate:self];
    [pageScrollViewCtrl setDelegateForDCDataLoaderMgr:nil];
    
    [currentDetailViewCtrl release];
    currentDetailViewCtrl = nil;
    [prevDetailViewCtrl release];
    prevDetailViewCtrl = nil;
    
    [pageScrollViewCtrl reloadPageViews];
    [pageScrollViewCtrl scrollToCurrentPageView];
}

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doPreviousActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl previousViewCtrl:(UIViewController *)previousViewCtrl {
    debug_NSLog(@"DCItemViewController pageScrollViewCtrl:doPreviousActionWithCurrentViewCtrl:previousViewCtrl:");
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
    }
    [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
    [pageScrollViewCtrl setDelegate:self];
    [pageScrollViewCtrl setDelegateForDCDataLoaderMgr:nil];
    
    [currentDetailViewCtrl release];
    currentDetailViewCtrl = nil;
    [nextDetailViewCtrl release];
    nextDetailViewCtrl = nil;
    
    [pageScrollViewCtrl reloadPageViews];
    [pageScrollViewCtrl scrollToCurrentPageView];
}

- (void)clearCache {
    [self.viewCache clear];
    [self.viewCache.dataLoader terminateAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
    [self.viewCache.dataLoader terminateAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
    
    if (self.dataLibraryHelper) {
        [self.dataLibraryHelper clearCacheInGroup:self.dataGroupUID];
    }
}

- (void)actionForWillEnterForegroud:(NSNotification *)note {
    if (self.navigationController.topViewController == self) {
        [self refresh:nil];
    }
}

- (void)actionForItemThumbnailLoaded:(NSNotification *)note {
    DCLoadThumbnailOperation *operation = (DCLoadThumbnailOperation *)[note object];
    [[DCDataModelHelper defaultDataModelHelper] createItemWithUID:operation.itemUID andThumbnail:operation.thumbnail];
    if (self.viewCache) {
        UIView *view = [self.viewCache getViewWithUID:operation.itemUID];
        if ([view isMemberOfClass:[DCItemView class]]) {
            DCItemView *itemView = (DCItemView *)view;
            itemView.thumbnail = operation.thumbnail;
            [itemView updateThumbnail];
        }
    }
}

- (void)dealloc {
    [self clearOperations];
    [self actionForDidUnload];
    
    if (_viewCache) {
        [_viewCache release];
        _viewCache = nil;
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
        id<DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
        debug_NSLog(@"groupID:%@ items count = %d", self.dataGroupUID, [group itemsCountWithParam:self.enumDataItemParam]);
        if ([group itemsCountWithParam:self.enumDataItemParam] == 0) {
            if (self.delegate) {
                [self.delegate popFormNavigationCtrl];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyRefreshGroup" object:self];
        } else {
            [self performSelectorInBackground:@selector(forceEnumAllItems) withObject:nil];
        }
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
}

- (void)refreshItems:(BOOL)force {
    debug_NSLog(@"DCItemViewController refreshItems:");
    if (self.dataLibraryHelper) {
        if (force || ![self.dataLibraryHelper isGroupEnumerated:self.dataGroupUID]) {
            NSUInteger pageViewCount = _itemCountInCell * [self calcVisiableRowNumber];
            [_viewCache setBufferTableCellNumber:pageViewCount * CACHE_BUFFERPAGE_ITEM];
            if (self.delegate) {
                [self.delegate dataRefreshStarted];
            }
//            [self clearCache];
            [self performSelectorOnMainThread:@selector(clearCache) withObject:nil waitUntilDone:YES];
            [self.dataLibraryHelper enumItems:self.enumDataItemParam inGroup:self.dataGroupUID notifyWithFrequency:pageViewCount];
        } else if (!force && [self.dataLibraryHelper isGroupEnumerated:self.dataGroupUID]) {
            [self.viewCache clearOperations];
            [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
            [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
            
            [self.viewCache loadBigThumbnailForCacheViews];
        }
        
        [self refreshItemViewTitle];
    }
}

- (void)refreshFirstScreen {
    debug_NSLog(@"DCItemViewController refreshFirstScreen");
    if (self.dataLibraryHelper) {
        if (![self.dataLibraryHelper isGroupEnumerated:self.dataGroupUID]) {
//            if (self.delegate) {
//                [self.delegate dataRefreshStarted];
//            }
//            [self clearCache];
            [self performSelectorOnMainThread:@selector(clearCache) withObject:nil waitUntilDone:YES];
            NSUInteger pageViewCount = _itemCountInCell * [self calcVisiableRowNumber];
            NSRange range;
            range.location = 0;
            range.length = pageViewCount;
            NSIndexSet *indexSet = [[[NSIndexSet alloc] initWithIndexesInRange:range] autorelease];
            [self.dataLibraryHelper enumItemAtIndexes:indexSet withParam:self.enumDataItemParam inGroup:self.dataGroupUID notifyWithFrequency:pageViewCount];
        }
        
        [self refreshItemViewTitle];
    }
}

- (void)refreshItemViewTitle {
    debug_NSLog(@"DCItemViewController refreshItemViewTitle");
    if (self.dataLibraryHelper) {
        id<DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
        if (!group) {
            [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper groupWithUID:%@ error", self.dataGroupUID];
            return;
        }
        NSString *groupName = [group valueForProperty:kDATAGROUPPROPERTY_GROUPNAME withOptions:nil];
        NSInteger numberOfItems = [group itemsCountWithParam:self.enumDataItemParam];
        
        _groupTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ (%d)", nil), groupName, numberOfItems];
        
        if (self.delegate) {
            [self.delegate itemViewCtrl:self setGroupTitle:self.groupTitle];
        }
    }
}

- (void)selectItem:(NSString *)itemUID showInPageScrollViewController:(DCPageScrollViewController *)pageScrollViewCtrl {
    if (itemUID && pageScrollViewCtrl && self.dataGroupUID && self.dataLibraryHelper) {
        /*** *** ***/ /*** *** ***/ /*** *** ***/ /*** *** ***/ /*** *** ***/ /*** *** ***/
        
        [self.viewCache clearOperations];
        [self.viewCache.dataLoader terminateAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
        [self.viewCache.dataLoader terminateAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        
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
        
        if (currentIndex < [self.dataLibraryHelper itemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID] - 1) {
            NSUInteger nextIndex = currentIndex + 1;
            NSString *nextItemUID = [self.dataLibraryHelper itemUIDAtIndex:nextIndex inGroup:self.dataGroupUID];
            nextDetailViewCtrl = [[[DCDetailViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:self.dataGroupUID itemUID:nextItemUID andIndexInGroup:nextIndex] autorelease];
            [nextDetailViewCtrl setDelegate:pageScrollViewCtrl];
        }
        
        [pageScrollViewCtrl setViewCtrlsWithCurrent:currentDetailViewCtrl previous:prevDetailViewCtrl andNext:nextDetailViewCtrl];
        [pageScrollViewCtrl setDelegate:self];
        [pageScrollViewCtrl setDelegateForDCDataLoaderMgr:nil];
        
        [pageScrollViewCtrl setScrollEnabled:YES];
        [pageScrollViewCtrl setHideNavigationBarEnabled:YES];
    } else {
        [NSException raise:@"DCItemViewController Error" format:@"Reason: assetURL is nil or self.groupPersistentID is nil or self.dataLibraryHelper is nil or pageScrollViewCtrl is nil"];
    }
}

- (void)reloadTableView:(NSNotification *)note {
    NSString *uid = (NSString *)[note object];
    if ([uid isEqualToString:self.dataGroupUID]) {
        debug_NSLog(@"DCItemViewController %@ reloadTableView:", self);
        [self.tableView reloadData];
    }
}

- (void)dataRefreshFinished:(NSNotification *)note {
    if (self.delegate) {
        [self.delegate dataRefreshFinished];
    }
}

- (void)dataFirstScreenRefreshFinished:(NSNotification *)note {
    debug_NSLog(@"DCItemViewController dataFirstScreenRefreshFinished:");
    [self performSelectorInBackground:@selector(enumAllItems) withObject:nil];
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
    double width = bounds.size.width - (tableViewMargin * 2);
    return (NSUInteger)((width - frameSize) / ((1 + 1.0 / 16) * frameSize) + 1.0);
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

- (NSUInteger)calcVisiableRowNumber {
    NSUInteger result = 0;
    if (_frameSize && _cellSpace) {
        result = self.tableView.bounds.size.height / (_frameSize + _cellSpace) + 1;
    }
    return result;
}

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        
        self.dataLibraryHelper = dataLibraryHelper;
        
        if (!_viewCache) {
            _viewCache = [[DCItemViewCache alloc] init];
            [_viewCache setDelegate:self];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    debug_NSLog(@"DCItemViewController %@ viewDidLoad:", self);
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setAllowsSelection:NO];
    
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self.tableView addGestureRecognizer:_pinchGestureRecognizer];
        _pinchScale = 0.0;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(reloadTableView:) name:NOTIFY_DATAITEM_ADDED object:nil];
    [notificationCenter addObserver:self selector:@selector(dataRefreshFinished:) name:NOTIFY_DATAITEM_ENUM_END object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForWillEnterForegroud:) name:@"applicationWillEnterForeground:" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForItemThumbnailLoaded:) name:NOTIFY_THUMBNAILLOADED object:nil];
    
    [self refreshItemViewTitle];
    
//    [self refreshItems:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    debug_NSLog(@"DCItemViewController %@ viewWillAppear:", self);
    [super viewWillAppear:animated];
    
    _frameSize = [self calcFrameSize];
    _tableViewMargin = [self calcTableViewMargin];
    _itemCountInCell = [self calcItemCountInCellWithFrameSize:_frameSize andTableViewMargin:_tableViewMargin];
    _cellSpace = [self calcCellSpaceWithFrameSize:_frameSize tableViewMargin:_tableViewMargin andItemCountInCell:_itemCountInCell];
    
    if ([self.dataLibraryHelper itemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID] > _itemCountInCell * [self calcVisiableRowNumber]) {
        [self refreshFirstScreen];
    } else {
        [self refreshItems:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    debug_NSLog(@"DCItemViewController %@ viewWillDisappear:", self);
    [self clearOperations];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    debug_NSLog(@"DCItemViewController %@ viewDidUnload:", self);
    [self actionForDidUnload];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)clearOperations {
    [self.viewCache clearOperations];
    [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
    [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
}

- (void)actionForDidUnload {
    if (_pinchGestureRecognizer) {
        _pinchScale = 0.0;
        [self.tableView removeGestureRecognizer:_pinchGestureRecognizer];
        [_pinchGestureRecognizer release];
        _pinchGestureRecognizer = nil;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
//    [self clearCache];
    [self performSelectorOnMainThread:@selector(clearCache) withObject:nil waitUntilDone:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    debug_NSLog(@"DCItemViewController shouldAutorotateToInterfaceOrientation:");
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
        
        [self.viewCache clear];
        [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
        [self.viewCache.dataLoader cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        
        [self.tableView reloadData];
    }
    
    return result;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    debug_NSLog(@"DCItemViewController %@ numberOfSectionsInTableView:", self);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    debug_NSLog(@"DCItemViewController %@ tableView:numberOfRowsInSection:", self);
    // Return the number of rows in the section.
    if (_itemCountInCell == 0) {
        return 0;
    }
    
    if (self.dataLibraryHelper) {
        return [self tableCellCount];
    } else {
        [NSException raise:@"DCItemViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    debug_NSLog(@"DCItemViewController %@ tableView:cellForRowAtIndexPath:", self);
    [self.viewCache.dataLoader queue:DATALODER_TYPE_VISIABLE pauseWithAutoResume:YES with:0.25];
    [self.viewCache.dataLoader queue:DATALODER_TYPE_BUFFER pauseWithAutoResume:YES with:0.25];
    DCItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCItemViewCell"];
    
    NSArray *views = [self.viewCache getViewsForTableCell:indexPath];
    
    if (cell == nil) {
        cell = [[[DCItemViewCell alloc] initWithDataItemViews:views cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell] autorelease];
    } else {
        [cell initWithDataItemViews:views cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell];
    }
    cell.delegate = self;
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

#pragma mark DCViewCacheDelegate
- (NSMutableArray *)getViewUIDsForTableCellAtIndexPath:(NSUInteger)index {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    if (self.dataLibraryHelper) {
        int maxIdx = MIN((index + 1) * _itemCountInCell, [self.dataLibraryHelper enumratedItemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID]); 
        for (int idx = 0 + index * _itemCountInCell; idx < maxIdx; ++idx) {
            [result addObject:[self.dataLibraryHelper itemUIDAtIndex:idx inGroup:self.dataGroupUID]];
            debug_NSLog(@"Get itemUID: %@ at index: %d", [self.dataLibraryHelper itemUIDAtIndex:idx inGroup:self.dataGroupUID], idx);
        }
    }
    return result;
}

- (UIView *)createViewWithUID:(NSString *)uid {
    DCItemView *itemView = nil;
    do {
        if (uid) {
            itemView = [[[DCItemView alloc] InitWithDataLibraryHelper:self.dataLibraryHelper itemUID:uid dataGroupUID:self.dataGroupUID andFrame:CGRectZero] autorelease];
            itemView.delegate = self.delegateForItemView;
            itemView.delegateForDCDataLoaderMgr = self.viewCache;
        }
    } while (NO);
    return itemView;
}

- (NSUInteger)visiableCellCount {
    return [self calcVisiableRowNumber];
}

- (NSUInteger)tableCellCount {
    NSInteger itemsCount = [self.dataLibraryHelper enumratedItemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID];
    debug_NSLog(@"itemsCount = %d", itemsCount);
    NSInteger addLine = 0;
    if (itemsCount % _itemCountInCell != 0) {
        addLine = 1;
    }
    return itemsCount / _itemCountInCell + addLine;
}

- (void)loadSmallThumbnailForView:(UIView *)view {
    do {
        if ([view isMemberOfClass:[DCItemView class]]) {
            DCItemView *itemView = (DCItemView *)view;
            [itemView loadSmallThumbnail];
        }
    } while (NO);
}

- (void)loadBigThumbnailInQueue:(enum DATALODER_TYPE)type forView:(UIView *)view {
    do {
        if ([view isMemberOfClass:[DCItemView class]]) {
            DCItemView *itemView = (DCItemView *)view;
            [itemView loadBigThumbnailInQueue:type];
        }
    } while (NO);
}


@end
