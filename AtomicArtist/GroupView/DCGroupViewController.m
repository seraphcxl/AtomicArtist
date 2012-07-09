//
//  DCGroupViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupViewController.h"
#import "DCItemViewController.h"
#import "DCItemPageScrollViewController.h"
#import "DCLoadPosterImageOperation.h"
#import "DCDataModelHelper.h"
#import "DCDataLoader.h"

@interface DCGroupViewController () {
    NSUInteger _itemCountInCell;
    NSUInteger _frameSize;
    double _cellSpace;
    NSUInteger _tableViewMargin;
    
//    NSMutableDictionary *_groupViews;
}

- (void)reloadTableView:(NSNotification *)note;
- (void)dataRefreshFinished:(NSNotification *)note;
- (void)notifyRefresh:(NSNotification *)note;
- (void)actionForWillEnterForegroud:(NSNotification *)note;
- (void)actionForGroupPosterImageLoaded:(NSNotification *)note;

- (double)calcCellSpaceWithFrameSize:(NSUInteger)frameSize tableViewMargin:(NSUInteger)tableViewMargin andItemCountInCell:(NSUInteger)itemCountInCell;

- (NSUInteger)calcItemCountInCellWithFrameSize:(NSUInteger)frameSize andTableViewMargin:(NSUInteger)tableViewMargin;

- (NSUInteger)calcFrameSize;

- (NSUInteger)calcTableViewMargin;

- (NSUInteger)calcVisiableRowNumber;

- (void)refreshGroups:(BOOL)force;

- (void)clearCache;

- (NSString *)title;

- (void)actionForWillDisappear;
- (void)actionForDidUnload;

@end

@interface DCGroupViewController ()

@end

@implementation DCGroupViewController

@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize type = _type;
@synthesize viewCache = _viewCache;
//@synthesize interfaceOrientation = _interfaceOrientation;

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doNextActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl nextViewCtrl:(UIViewController *)nextViewCtrl {
    NSLog(@"DCGroupViewController pageScrollViewCtrl:doNextActionWithCurrentViewCtrl:nextViewCtrl:");
    if (![pageScrollViewCtrl isMemberOfClass:[DCItemPageScrollViewController class]]) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: pageScrollViewCtrl class: %@", [pageScrollViewCtrl class]];
        return;
    }
    DCItemViewController *currentItemViewCtrl = (DCItemViewController *)nextViewCtrl;
    [currentItemViewCtrl retain];
    DCItemViewController *prevItemViewCtrl = (DCItemViewController *)currentViewCtrl;
    [prevItemViewCtrl retain];
    DCItemViewController *nextItemViewCtrl = nil;
    if (currentItemViewCtrl.dataGroupIndex == ([self.dataLibraryHelper groupsCount] - 1)) {
        ;
    } else {
        NSUInteger nextIndex = currentItemViewCtrl.dataGroupIndex + 1;
        NSString *nextItemUID = [self.dataLibraryHelper groupUIDAtIndex:nextIndex];
        nextItemViewCtrl = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
        nextItemViewCtrl.dataGroupUID = nextItemUID;
        nextItemViewCtrl.dataGroupIndex = nextIndex;
        nextItemViewCtrl.enumDataItemParam = _enumDataItemParam;
        nextItemViewCtrl.delegateForItemView = (DCItemPageScrollViewController *)pageScrollViewCtrl;
    }
    [pageScrollViewCtrl setViewCtrlsWithCurrent:currentItemViewCtrl previous:prevItemViewCtrl andNext:nextItemViewCtrl];
    
    [currentItemViewCtrl release];
    currentItemViewCtrl = nil;
    [prevItemViewCtrl release];
    prevItemViewCtrl = nil;
    
    [pageScrollViewCtrl reloadPageViews];
    [pageScrollViewCtrl scrollToCurrentPageView];
}

- (void)pageScrollViewCtrl:(DCPageScrollViewController *)pageScrollViewCtrl doPreviousActionWithCurrentViewCtrl:(UIViewController *)currentViewCtrl previousViewCtrl:(UIViewController *)previousViewCtrl {
    NSLog(@"DCItemViewController pageScrollViewCtrl:doPreviousActionWithCurrentViewCtrl:previousViewCtrl:");
    if (![pageScrollViewCtrl isMemberOfClass:[DCItemPageScrollViewController class]]) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: pageScrollViewCtrl class: %@", [pageScrollViewCtrl class]];
        return;
    }
    DCItemViewController *currentItemViewCtrl = (DCItemViewController *)previousViewCtrl;
    [currentItemViewCtrl retain];
    DCItemViewController *prevItemViewCtrl = nil;
    DCItemViewController *nextItemViewCtrl = (DCItemViewController *)currentViewCtrl;
    [nextItemViewCtrl retain];
    if (currentItemViewCtrl.dataGroupIndex == 0) {
        ;
    } else {
        NSUInteger prevIndex = currentItemViewCtrl.dataGroupIndex - 1;
        NSString *prevItemUID = [self.dataLibraryHelper groupUIDAtIndex:prevIndex];
        prevItemViewCtrl = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
        prevItemViewCtrl.dataGroupUID = prevItemUID;
        prevItemViewCtrl.dataGroupIndex = prevIndex;
        prevItemViewCtrl.enumDataItemParam = _enumDataItemParam;
        prevItemViewCtrl.delegateForItemView = (DCItemPageScrollViewController *)pageScrollViewCtrl;
    }
    [pageScrollViewCtrl setViewCtrlsWithCurrent:currentItemViewCtrl previous:prevItemViewCtrl andNext:nextItemViewCtrl];
    
    [currentItemViewCtrl release];
    currentItemViewCtrl = nil;
    [nextItemViewCtrl release];
    nextItemViewCtrl = nil;
    
    [pageScrollViewCtrl reloadPageViews];
    [pageScrollViewCtrl scrollToCurrentPageView];
}

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
        
//        _frameSize = [self calcFrameSize];
//        _itemCountInCell = [self calcItemCountInCellWithFrameSize:_frameSize];
//        _cellSpace = [self calcCellSpaceWithFrameSize:_frameSize andItemCountInCell:_itemCountInCell];
        
        if (!_viewCache) {
            _viewCache = [[DCGroupViewCache alloc] init];
            [_viewCache setDelegate:self];
        }
        
        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
        [self.navigationItem setRightBarButtonItem:bbi];
    }
    return self;
}

- (void)dealloc {
    [self actionForWillDisappear];
    [self actionForDidUnload];
    
    if (_viewCache) {
        [_viewCache release];
        _viewCache = nil;
    }
    
    self.dataLibraryHelper = nil;
    
    [super dealloc];
}

- (void)clearCache {
    [self.viewCache clear];
    [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
    [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
    
    [self.dataLibraryHelper clearCache];
}

- (void)actionForWillEnterForegroud:(NSNotification *)note {
    if (self.navigationController.topViewController == self) {
        [self refreshGroups:YES];
    }
}

- (void)actionForGroupPosterImageLoaded:(NSNotification *)note {
    DCLoadPosterImageOperation *operation = (DCLoadPosterImageOperation *)[note object];
    [[DCDataModelHelper defaultDataModelHelper] createGroupWithUID:operation.dataGroupUID posterItemUID:operation.itemUID andPosterImage:operation.thumbnail];
    if (self.viewCache) {
        UIView *view = [self.viewCache getViewWithUID:operation.dataGroupUID];
        if ([view isMemberOfClass:[DCGroupView class]]) {
            DCGroupView *groupView = (DCGroupView *)view;
            groupView.posterImage = operation.thumbnail;
            [groupView updatePosterImage];
        }
        
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
        NSUInteger pageViewCount = _itemCountInCell * [self calcVisiableRowNumber];
        
        [_viewCache setBufferTableCellNumber:pageViewCount * CACHE_BUFFERPAGE_GROUP];
        
        UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [activityIndicatorView startAnimating];
        UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView] autorelease];
        [self.navigationItem setRightBarButtonItem:bbi];
        
        [self clearCache];
        [self.dataLibraryHelper enumGroups:_enumDataGroupParam notifyWithFrequency:pageViewCount];
        [self.navigationItem setTitle:[self title]];
    } else if (!force && [self.dataLibraryHelper groupsCount] != 0){
        [self.viewCache loadBigThumbnailForCacheViews];
    }
}

- (void)selectGroup:(NSString *)dataGroupUID {
    if (dataGroupUID && self.dataLibraryHelper) {
        
        [[DCDataLoader defaultDataLoader] queue:DATALODER_TYPE_VISIABLE pauseWithAutoResume:NO with:0.0];

//        NSUInteger index = [self.dataLibraryHelper indexForGroupUID:dataGroupUID];
//        DCItemViewController *itemViewController = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
//        itemViewController.dataGroupUID = dataGroupUID;
//        itemViewController.dataGroupIndex = index;
//        itemViewController.enumDataItemParam = _enumDataItemParam;
//        [self.navigationController pushViewController:itemViewController animated:YES];
        DCItemPageScrollViewController *pageScrollViewCtrl = [[[DCItemPageScrollViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        
        DCItemViewController *currentItemViewCtrl = nil;
        DCItemViewController *prevItemViewCtrl = nil;
        DCItemViewController *nextItemViewCtrl = nil;
        
        NSUInteger currentIndex = [self.dataLibraryHelper indexForGroupUID:dataGroupUID];
        currentItemViewCtrl = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
        currentItemViewCtrl.dataGroupUID = dataGroupUID;
        currentItemViewCtrl.dataGroupIndex = currentIndex;
        currentItemViewCtrl.enumDataItemParam = _enumDataItemParam;
        currentItemViewCtrl.delegateForItemView = pageScrollViewCtrl;
        currentItemViewCtrl.delegate = pageScrollViewCtrl;
        
        if (currentIndex != 0) {
            NSUInteger prevIndex = currentIndex - 1;
            NSString *prevItemUID = [self.dataLibraryHelper groupUIDAtIndex:prevIndex];
            prevItemViewCtrl = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
            prevItemViewCtrl.dataGroupUID = prevItemUID;
            prevItemViewCtrl.dataGroupIndex = prevIndex;
            prevItemViewCtrl.enumDataItemParam = _enumDataItemParam;
            prevItemViewCtrl.delegateForItemView = pageScrollViewCtrl;
            prevItemViewCtrl.delegate = pageScrollViewCtrl;
        }
        
        if (currentIndex < [self.dataLibraryHelper groupsCount] - 1) {
            NSUInteger nextIndex = currentIndex + 1;
            NSString *nextItemUID = [self.dataLibraryHelper groupUIDAtIndex:nextIndex];
            nextItemViewCtrl = [[[DCItemViewController alloc] initWithDataLibraryHelper:self.dataLibraryHelper] autorelease];
            nextItemViewCtrl.dataGroupUID = nextItemUID;
            nextItemViewCtrl.dataGroupIndex = nextIndex;
            nextItemViewCtrl.enumDataItemParam = _enumDataItemParam;
            nextItemViewCtrl.delegateForItemView = pageScrollViewCtrl;
            nextItemViewCtrl.delegate = pageScrollViewCtrl;
        }
        
        [pageScrollViewCtrl setViewCtrlsWithCurrent:currentItemViewCtrl previous:prevItemViewCtrl andNext:nextItemViewCtrl];
        [pageScrollViewCtrl setDelegate:self];
        [pageScrollViewCtrl setScrollEnabled:YES];
        [pageScrollViewCtrl setHideNavigationBarEnabled:NO];
        [self.navigationController pushViewController:pageScrollViewCtrl animated:YES];
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: dataGroupUID == nil"];
    }
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

- (NSUInteger)calcTableViewMargin {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return GROUPVIEW_TABLEVIEW_MARGIN_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return GROUPVIEW_TABLEVIEW_MARGIN_IPAD;
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSUInteger)calcVisiableRowNumber {
    NSUInteger result = 0;
    if (_frameSize && _cellSpace) {
        result = self.tableView.bounds.size.height / (_frameSize + _cellSpace) + 1;
    }
    return result;
}

- (NSUInteger)calcItemCountInCellWithFrameSize:(NSUInteger)frameSize andTableViewMargin:(NSUInteger)tableViewMargin {
    if (frameSize == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: frameSize == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    double width = bounds.size.width - (tableViewMargin * 2);
    return (NSUInteger)((width - frameSize) / ((1 + 1.0 / 16) * frameSize) + 1.0);
}

- (double)calcCellSpaceWithFrameSize:(NSUInteger)frameSize tableViewMargin:(NSUInteger)tableViewMargin andItemCountInCell:(NSUInteger)itemCountInCell {
    if (frameSize == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: frameSize == 0"];
    }
    if (itemCountInCell == 0) {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: itemCountInCell == 0"];
    }
    CGRect bounds = [self.tableView bounds];
    return ((bounds.size.width - (tableViewMargin * 2) - (itemCountInCell * frameSize)) * 1.0 / (itemCountInCell - 1));
}

- (void)reloadTableView:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)dataRefreshFinished:(NSNotification *)note {
    UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    [self.navigationItem setRightBarButtonItem:bbi];
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
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(reloadTableView:) name:NOTIFY_DATAGROUP_ADDED object:nil];
    [notificationCenter addObserver:self selector:@selector(dataRefreshFinished:) name:NOTIFY_DATAGROUP_ENUM_END object:nil];
    [notificationCenter addObserver:self selector:@selector(notifyRefresh:) name:@"NotifyRefreshGroup" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForWillEnterForegroud:) name:@"applicationWillEnterForeground:" object:nil];
    [notificationCenter addObserver:self selector:@selector(actionForGroupPosterImageLoaded:) name:NOTIFY_POSTERIMAGELOADED object:nil];
    /*** *** ***/
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"DCGroupViewController viewWillAppear:");
    [super viewWillAppear:animated];
    
    _frameSize = [self calcFrameSize];
    _tableViewMargin = [self calcTableViewMargin];
    _itemCountInCell = [self calcItemCountInCellWithFrameSize:_frameSize andTableViewMargin:_tableViewMargin];
    _cellSpace = [self calcCellSpaceWithFrameSize:_frameSize tableViewMargin:_tableViewMargin andItemCountInCell:_itemCountInCell];
    
    [self.viewCache clearOperations];
//    [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
//    [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
    
    [self refreshGroups:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"DCGroupViewController viewWillDisappear:");
    
    [self actionForWillDisappear];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"DCGroupViewController viewDidUnload:");
    /*** *** ***/
    [self actionForDidUnload];
    /*** *** ***/
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)actionForWillDisappear {
    [self.viewCache clearOperations];
    [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
    [[DCDataLoader defaultDataLoader] terminateAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
}

- (void)actionForDidUnload {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self clearCache];
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
        [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_VISIABLE];
        [[DCDataLoader defaultDataLoader] cancelAllOperationsOnQueue:DATALODER_TYPE_BUFFER];
        
        [self.tableView reloadData];
    }
    
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
        return 0;
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
    
    [[DCDataLoader defaultDataLoader] queue:DATALODER_TYPE_VISIABLE pauseWithAutoResume:YES with:1.0];
    
    NSArray *views = [self.viewCache getViewsForTableCell:indexPath];
    
    DCGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCGroupViewCell"];
    if (cell == nil) {
        cell = [[[DCGroupViewCell alloc] initWithDataGroupViews:views cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell] autorelease];
    } else {
        [cell initWithDataGroupViews:views cellSpace:_cellSpace cellTopBottomMargin:(_cellSpace / 2) tableViewMargin:_tableViewMargin frameSize:_frameSize andItemCount:_itemCountInCell];
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
        int maxIdx = MIN((index + 1) * _itemCountInCell, [self.dataLibraryHelper groupsCount]); 
        for (int idx = 0 + index * _itemCountInCell; idx < maxIdx; ++idx) {
            [result addObject:[self.dataLibraryHelper groupUIDAtIndex:idx]];
            NSLog(@"Get DataGoupUID: %@ at index: %d", [self.dataLibraryHelper groupUIDAtIndex:idx], idx);
        }
    } else {
        [NSException raise:@"DCGroupViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
    
    return result;
}

- (UIView *)createViewWithUID:(NSString *)uid {
    DCGroupView *groupView = nil;
    do {
        if (uid) {
            groupView = [[[DCGroupView alloc] InitWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:uid enumDataItemParam:_enumDataItemParam andFrame:CGRectZero] autorelease];
            groupView.delegate = self;
        }
    } while (NO);
    return groupView;
}

- (NSUInteger)visiableCellCount {
    return _itemCountInCell * [self calcVisiableRowNumber];
}

- (NSUInteger)tableCellCount {
    return [self.dataLibraryHelper groupsCount];
}

- (void)loadSmallThumbnailForView:(UIView *)view {
    do {
        if ([view isMemberOfClass:[DCGroupView class]]) {
            DCGroupView *groupView = (DCGroupView *)view;
            [groupView loadSmallThumbnail];
        }
    } while (NO);
}

- (void)loadBigThumbnailInQueue:(enum DATALODER_TYPE)type forView:(UIView *)view {
    do {
        if ([view isMemberOfClass:[DCGroupView class]]) {
            DCGroupView *groupView = (DCGroupView *)view;
            [groupView loadBigThumbnailInQueue:type];
        }
    } while (NO);
}

@end
