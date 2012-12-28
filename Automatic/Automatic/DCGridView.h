//
//  DCGridView.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "DCGridViewCell.h"

@protocol DCGridViewDataSource;
@protocol DCGridViewActionDelegate;
@protocol DCGridViewSortingDelegate;
@protocol DCGridViewTransformationDelegate;
@protocol DCGridViewLayoutStrategy;

typedef enum {
    DCGridViewStylePush = 0,
    DCGridViewStyleSwap,
} DCGridViewStyle;

typedef enum {
	DCGridViewScrollPositionNone = 0,
	DCGridViewScrollPositionTop,
	DCGridViewScrollPositionMiddle,
	DCGridViewScrollPositionBottom,
} DCGridViewScrollPosition;

typedef enum {
    DCGridViewItemAnimationNone = 0,
    DCGridViewItemAnimationFade,
    DCGridViewItemAnimationScroll = 1<<7 // scroll to the item before showing the animation
} DCGridViewItemAnimation;


#pragma mark - interface DCGridView : UIScrollView
@interface DCGridView : UIScrollView

// Delegates
@property(nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet NSObject<DCGridViewDataSource> *dataSource;  // Required
@property(nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet NSObject<DCGridViewActionDelegate> *actionDelegate;  // Optional - to get taps callback & deleting item
@property(nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet NSObject<DCGridViewSortingDelegate> *sortingDelegate;  // Optional - to enable sorting
@property(nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet NSObject<DCGridViewTransformationDelegate> *transformDelegate;  // Optional - to enable fullsize mode

// Layout Strategy
@property(nonatomic, SAFE_ARC_PROP_STRONG) IBOutlet id<DCGridViewLayoutStrategy> layoutStrategy;  // Default is DCGridViewLayoutVerticalStrategy

// Editing Mode
@property(nonatomic, getter = isEditing) BOOL editing;  // Default is NO - When set to YES, all gestures are disabled and delete buttons shows up on cells
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

// Customizing Options
@property(nonatomic, SAFE_ARC_PROP_WEAK) IBOutlet UIView *mainSuperView;  // Default is self
@property(nonatomic) DCGridViewStyle style;  // Default is DCGridViewStyleSwap
@property(nonatomic) NSInteger itemSpacing;  // Default is 8
@property(nonatomic) BOOL centerGrid;  // Default is YES
@property(nonatomic) UIEdgeInsets minEdgeInsets;  // Default is (4, 4, 4, 4)
@property(nonatomic) CFTimeInterval minimumPressDuration;  // Default is 0.2; if set to 0, the view wont be scrollable
@property(nonatomic) BOOL showFullSizeViewWithAlphaWhenTransforming;  // Default is YES - not working right now
@property(nonatomic) BOOL enableEditOnLongPress;  // Default is NO
@property(nonatomic) BOOL disableEditOnEmptySpaceTap;  // Default is NO

@property(nonatomic, readonly) UIScrollView *scrollView __attribute__((deprecated));  // The grid now inherits directly from UIScrollView

// Reusable cells
- (DCGridViewCell *)dequeueReusableCell;  // Should be called in DCGridView:cellForItemAtIndex: to reuse a cell
- (DCGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

// Cells
- (DCGridViewCell *)cellForItemAtIndex:(NSInteger)position;  // Might return nil if cell not loaded yet

// Actions
- (void)reloadData;
- (void)insertObjectAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation;
- (void)removeObjectAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation;
- (void)reloadObjectAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation;
- (void)swapObjectAtIndex:(NSInteger)index1 withObjectAtIndex:(NSInteger)index2 animated:(BOOL)animated;
- (void)swapObjectAtIndex:(NSInteger)index1 withObjectAtIndex:(NSInteger)index2 withAnimation:(DCGridViewItemAnimation)animation;
- (void)scrollToObjectAtIndex:(NSInteger)index atScrollPosition:(DCGridViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Force the grid to update properties in an (probably) animated way.
- (void)layoutSubviewsWithAnimation:(DCGridViewItemAnimation)animation;

@end


#pragma mark - protocol DCGridViewDataSource <NSObject>
@protocol DCGridViewDataSource <NSObject>

@required
// Populating subview items
- (NSInteger)numberOfItemsInDCGridView:(DCGridView *)gridView;
- (CGSize)DCGridView:(DCGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (DCGridViewCell *)DCGridView:(DCGridView *)gridView cellForItemAtIndex:(NSInteger)index;

@optional
// Allow a cell to be deletable. If not implemented, YES is assumed.
- (BOOL)DCGridView:(DCGridView *)gridView canDeleteItemAtIndex:(NSInteger)index;

@end


#pragma mark - protocol DCGridViewActionDelegate <NSObject>
@protocol DCGridViewActionDelegate <NSObject>

@required
- (void)DCGridView:(DCGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;

@optional
// Tap on space without any items
- (void)DCGridViewDidTapOnEmptySpace:(DCGridView *)gridView;
// Called when the delete-button has been pressed. Required to enable editing mode.
// This method wont delete the cell automatically. Call the delete method of the gridView when appropriate.
- (void)DCGridView:(DCGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index;

- (void)DCGridView:(DCGridView *)gridView changedEdit:(BOOL)edit;

@end


#pragma mark - protocol DCGridViewSortingDelegate <NSObject>
@protocol DCGridViewSortingDelegate <NSObject>

@required
// Item moved - right place to update the data structure
- (void)DCGridView:(DCGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex;
- (void)DCGridView:(DCGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2;

@optional
// Sorting started/ended - indexes are not specified on purpose (not the right place to update data structure)
- (void)DCGridView:(DCGridView *)gridView didStartMovingCell:(DCGridViewCell *)cell;
- (void)DCGridView:(DCGridView *)gridView didEndMovingCell:(DCGridViewCell *)cell;
// Enable/Disable the shaking behavior of an item being moved
- (BOOL)DCGridView:(DCGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(DCGridViewCell *)view atIndex:(NSInteger)index;

@end


#pragma mark - protocol DCGridViewTransformationDelegate <NSObject>
@protocol DCGridViewTransformationDelegate <NSObject>

@required
// Fullsize
- (CGSize)DCGridView:(DCGridView *)gridView sizeInFullSizeForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (UIView *)DCGridView:(DCGridView *)gridView fullSizeViewForCell:(DCGridViewCell *)cell atIndex:(NSInteger)index;

// Transformation (pinch, drag, rotate) of the item
@optional
- (void)DCGridView:(DCGridView *)gridView didStartTransformingCell:(DCGridViewCell *)cell;
- (void)DCGridView:(DCGridView *)gridView didEnterFullSizeForCell:(DCGridViewCell *)cell;
- (void)DCGridView:(DCGridView *)gridView didEndTransformingCell:(DCGridViewCell *)cell;

@end

