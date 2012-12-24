//
//  DCGridView.m
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "DCGridView.h"
#import <QuartzCore/QuartzCore.h>
#import "DCGridViewCell_Extended.h"
#import "DCGridViewLayoutStrategies.h"
#import "UIGestureRecognizer+DCGridViewAdditions.h"

static const NSInteger kTagOffset = 48;
static const CGFloat kDefaultAnimationDuration = 0.25;
static const UIViewAnimationOptions kDefaultAnimationOptions = (UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction);


#pragma mark - interface DCGridView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@interface DCGridView () <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
    // Sorting Gestures
    UIPanGestureRecognizer *_sortingPanGesture;
    UILongPressGestureRecognizer *_longPressGesture;
    
    // Moving gestures
    UIPinchGestureRecognizer *_pinchGesture;
    UITapGestureRecognizer *_tapGesture;
    UIRotationGestureRecognizer *_rotationGesture;
    UIPanGestureRecognizer *_panGesture;
    
    // General vars
    NSInteger _numberTotalItems;
    CGSize _itemSize;
    NSMutableSet *_reusableCells;
    
    // Moving (sorting) control vars
    DCGridViewCell *_sortMovingItem;
    NSInteger _sortFuturePosition;
    BOOL _autoScrollActive;
    
    CGPoint _minPossibleContentOffset;
    CGPoint _maxPossibleContentOffset;
    
    // Transforming control vars
    DCGridViewCell *_transformingItem;
    CGFloat _lastRotation;
    CGFloat _lastScale;
    BOOL _inFullSizeMode;
    BOOL _inTransformingState;
    
    // Rotation
    BOOL _rotationActive;
}

@property(nonatomic, readonly) BOOL itemsSubviewsCacheIsValid;
@property(nonatomic, strong) NSArray *itemSubviewsCache;
@property(atomic) NSInteger firstPositionLoaded;
@property(atomic) NSInteger lastPositionLoaded;

- (void)commonInit;

// Gestures
- (void)sortingPanGestureUpdated:(UIPanGestureRecognizer *)panGesture;
- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture;
- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture;
- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture;
- (void)pinchGestureUpdated:(UIPinchGestureRecognizer *)pinchGesture;
- (void)rotationGestureUpdated:(UIRotationGestureRecognizer *)rotationGesture;

// Sorting movement control
- (void)sortingMoveDidStartAtPoint:(CGPoint)point;
- (void)sortingMoveDidContinueToPoint:(CGPoint)point;
- (void)sortingMoveDidStopAtPoint:(CGPoint)point;
- (void)sortingAutoScrollMovementCheck;

// Transformation control
- (void)transformingGestureDidBeginWithGesture:(UIGestureRecognizer *)gesture;
- (void)transformingGestureDidFinish;
- (BOOL)isInTransformingState;

// Helpers & more
- (void)recomputeSizeAnimated:(BOOL)animated;
- (void)relayoutItemsAnimated:(BOOL)animated;
- (NSArray *)itemSubviews;
- (DCGridViewCell *)cellForItemAtIndex:(NSInteger)position;
- (DCGridViewCell *)newItemSubViewForPosition:(NSInteger)position;
- (NSInteger)positionForItemSubview:(DCGridViewCell *)view;
- (void)setSubviewsCacheAsInvalid;
- (CGRect)rectForPoint:(CGPoint)point inPaggingMode:(BOOL)pagging;

// Lazy loading
- (void)loadRequiredItems;
- (void)cleanupUnseenItems;
- (void)queueReusableCell:(DCGridViewCell *)cell;

// Memory warning
- (void)receivedMemoryWarningNotification:(NSNotification *)notification;

// Rotation handling
- (void)receivedWillRotateNotification:(NSNotification *)notification;

@end


#pragma mark - implementation DCGridView
@implementation DCGridView

@synthesize sortingDelegate = _sortingDelegate;
@synthesize dataSource = _dataSource;
@synthesize transformDelegate = _transformDelegate;
@synthesize actionDelegate = _actionDelegate;
@synthesize mainSuperView = _mainSuperView;
@synthesize layoutStrategy = _layoutStrategy;
@synthesize itemSpacing = _itemSpacing;
@synthesize style = _style;
@synthesize minimumPressDuration;
@synthesize centerGrid = _centerGrid;
@synthesize minEdgeInsets = _minEdgeInsets;
@synthesize showFullSizeViewWithAlphaWhenTransforming;
@synthesize editing = _editing;
@synthesize enableEditOnLongPress = _enableEditOnLongPress;
@synthesize disableEditOnEmptySpaceTap = _disableEditOnEmptySpaceTap;

@synthesize itemsSubviewsCacheIsValid = _itemsSubviewsCacheIsValid;
@synthesize itemSubviewsCache = _itemSubviewsCache;

@synthesize firstPositionLoaded = _firstPositionLoaded;
@synthesize lastPositionLoaded = _lastPositionLoaded;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    do {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
        _tapGesture.delegate = self;
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
        _tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_tapGesture];
        
        /////////////////////////////
        // Transformation gestures :
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureUpdated:)];
        _pinchGesture.delegate = self;
        [self addGestureRecognizer:_pinchGesture];
        
        _rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureUpdated:)];
        _rotationGesture.delegate = self;
        [self addGestureRecognizer:_rotationGesture];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdated:)];
        _panGesture.delegate = self;
        [_panGesture setMaximumNumberOfTouches:2];
        [_panGesture setMinimumNumberOfTouches:2];
        [self addGestureRecognizer:_panGesture];
        
        //////////////////////
        // Sorting gestures :
        
        _sortingPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sortingPanGestureUpdated:)];
        _sortingPanGesture.delegate = self;
        [self addGestureRecognizer:_sortingPanGesture];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
        _longPressGesture.numberOfTouchesRequired = 1;
        _longPressGesture.delegate = self;
        _longPressGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_longPressGesture];
        
        ////////////////////////
        // Gesture dependencies
        UIPanGestureRecognizer *panGestureRecognizer = nil;
        if ([self respondsToSelector:@selector(panGestureRecognizer)]) // iOS5 only
        {
            panGestureRecognizer = self.panGestureRecognizer;
        }
        else
        {
            for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers)
            {
                if ([gestureRecognizer  isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")])
                {
                    panGestureRecognizer = (UIPanGestureRecognizer *) gestureRecognizer;
                }
            }
        }
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        [panGestureRecognizer requireGestureRecognizerToFail:_sortingPanGesture];
        
        self.layoutStrategy = [DCGridViewLayoutStrategyFactory strategyFromType:DCGridViewLayoutVertical];
        
        self.mainSuperView = self;
        self.editing = NO;
        self.itemSpacing = 8;
        self.style = DCGridViewStyleSwap;
        self.minimumPressDuration = 0.2;
        self.showFullSizeViewWithAlphaWhenTransforming = YES;
        self.minEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        self.clipsToBounds = NO;
        
        _sortFuturePosition = DCGV_INVALID_POSITION;
        _itemSize = CGSizeZero;
        _centerGrid = YES;
        
        _lastScale = 1.0;
        _lastRotation = 0.0;
        
        _minPossibleContentOffset = CGPointMake(0, 0);
        _maxPossibleContentOffset = CGPointMake(0, 0);
        
        _reusableCells = [[NSMutableSet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillRotateNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    } while (NO);
}

- (void)dealloc {
    do {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    } while (NO);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - DCGridView - layout
- (void)applyWithoutAnimation:(void (^)(void))animations {
    do {
        if (animations) {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            animations();
            [CATransaction commit];
        }
    } while (NO);
}

- (void)layoutSubviewsWithAnimation:(DCGridViewItemAnimation)animation {
    do {
        [self recomputeSizeAnimated:!(animation & DCGridViewItemAnimationNone)];
        [self relayoutItemsAnimated:animation & DCGridViewItemAnimationFade]; // only supported animation for now
        [self loadRequiredItems];
    } while (NO);
}

- (void)layoutSubviews {
    do {
        [super layoutSubviews];
        
        if (_rotationActive) {
            _rotationActive = NO;
            
            // Updating all the items size
            
            CGSize itemSize = [self.dataSource DCGridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            
            if (!CGSizeEqualToSize(_itemSize, itemSize)) {
                _itemSize = itemSize;
                
                [[self itemSubviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (obj != _transformingItem) {
                        DCGridViewCell *cell = (DCGridViewCell *)obj;
                        cell.bounds = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
                        cell.contentView.frame = cell.bounds;
                    }
                }];
            }
            
            // Updating the fullview size
            
            if (_transformingItem && _inFullSizeMode) {
                NSInteger position = _transformingItem.tag - kTagOffset;
                CGSize fullSize = [self.transformDelegate DCGridView:self sizeInFullSizeForCell:_transformingItem atIndex:position inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                
                if (!CGSizeEqualToSize(fullSize, _transformingItem.fullSize)) {
                    CGPoint center = _transformingItem.fullSizeView.center;
                    _transformingItem.fullSize = fullSize;
                    _transformingItem.fullSizeView.center = center;
                }
            }
            
            // Adding alpha animation to make the relayouting more smooth
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.25f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [self.layer addAnimation:transition forKey:@"rotationAnimation"];
            
            [self applyWithoutAnimation:^{
                [self layoutSubviewsWithAnimation:DCGridViewItemAnimationNone];
            }];
            
            // Fixing the contentOffset when pagging enabled
            
            if (self.pagingEnabled) {
                [self setContentOffset:[self rectForPoint:self.contentOffset inPaggingMode:YES].origin animated:YES];
            }
        } else {
            [self layoutSubviewsWithAnimation:DCGridViewItemAnimationNone];
        }
    } while (NO);
}

#pragma mark - DCGridView - Orientation and memory management
- (void)receivedMemoryWarningNotification:(NSNotification *)notification {
    do {
        [self cleanupUnseenItems];
        [_reusableCells removeAllObjects];
    } while (NO);
}

- (void)receivedWillRotateNotification:(NSNotification *)notification {
    _rotationActive = YES;
}

#pragma mark - DCGridView - Setters / getters
- (void)setDataSource:(NSObject<DCGridViewDataSource> *)dataSource {
    do {
        _dataSource = dataSource;
        [self reloadData];
    } while (NO);
}

- (void)setMainSuperView:(UIView *)mainSuperView {
    do {
        _mainSuperView = (mainSuperView != nil ? mainSuperView : self);
    } while (NO);
}

- (void)setLayoutStrategy:(id<DCGridViewLayoutStrategy>)layoutStrategy {
    do {
        _layoutStrategy = layoutStrategy;
        
        self.pagingEnabled = [[self.layoutStrategy class] requiresEnablingPaging];
        [self setNeedsLayout];
    } while (NO);
}

- (void)setItemSpacing:(NSInteger)itemSpacing {
    do {
        _itemSpacing = itemSpacing;
        [self setNeedsLayout];
    } while (NO);
}

- (void)setCenterGrid:(BOOL)centerGrid {
    do {
        _centerGrid = centerGrid;
        [self setNeedsLayout];
    } while (NO);
}

- (void)setMinEdgeInsets:(UIEdgeInsets)minEdgeInsets {
    do {
        _minEdgeInsets = minEdgeInsets;
        [self setNeedsLayout];
    } while (NO);
}

- (void)setMinimumPressDuration:(CFTimeInterval)duration {
    do {
        _longPressGesture.minimumPressDuration = duration;
    } while (NO);
}

- (CFTimeInterval)minimumPressDuration {
    return _longPressGesture.minimumPressDuration;
}

- (void)setEditing:(BOOL)editing {
    do {
        [self setEditing:editing animated:NO];
        
        if ([self.actionDelegate respondsToSelector:@selector(DCGridView:changedEdit:)]) {
            [self.actionDelegate DCGridView:self changedEdit:editing];
        }
    } while (NO);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    do {
        if ([self.actionDelegate respondsToSelector:@selector(DCGridView:processDeleteActionForItemAtIndex:)] &&![self isInTransformingState] && ((self.isEditing && !editing) || (!self.isEditing && editing))) {
            for (DCGridViewCell *cell in [self itemSubviews]) {
                NSInteger index = [self positionForItemSubview:cell];
                if (index != DCGV_INVALID_POSITION) {
                    BOOL allowEdit = editing && [self.dataSource DCGridView:self canDeleteItemAtIndex:index];
                    [cell setEditing:allowEdit animated:animated];
                }
            }
            
            _editing = editing;
        }
    } while (NO);
}

#pragma mark - DCGridView - UIScrollView delegate replacement
- (void)contentOffset:(CGPoint)contentOffset {
    do {
        BOOL valueChanged = !CGPointEqualToPoint(contentOffset, self.contentOffset);
        
        [super setContentOffset:contentOffset];
        
        if (valueChanged) {
            [self loadRequiredItems];
        }
    } while (NO);
}

#pragma mark - DCGridView - GestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL valid = YES;
    do {
        BOOL isScrolling = (self.isDragging || self.isDecelerating);
        
        if (gestureRecognizer == _tapGesture) {
            if (self.editing && self.disableEditOnEmptySpaceTap) {
                CGPoint locationTouch = [_tapGesture locationInView:self];
                NSInteger position = [self.layoutStrategy itemPositionFromLocation:locationTouch];
                
                valid = (position == DCGV_INVALID_POSITION);
            } else {
                valid = (!isScrolling && !self.isEditing && ![_longPressGesture hasRecognizedValidGesture]);
            }
        } else if (gestureRecognizer == _longPressGesture) {
            valid = ((self.sortingDelegate || self.enableEditOnLongPress) && !isScrolling && !self.isEditing);
        } else if (gestureRecognizer == _sortingPanGesture) {
            valid = (_sortMovingItem != nil && [_longPressGesture hasRecognizedValidGesture]);
        } else if (gestureRecognizer == _rotationGesture || gestureRecognizer == _pinchGesture || gestureRecognizer == _panGesture) {
            if (self.transformDelegate != nil && [gestureRecognizer numberOfTouches] == 2) {
                CGPoint locationTouch1 = [gestureRecognizer locationOfTouch:0 inView:self];
                CGPoint locationTouch2 = [gestureRecognizer locationOfTouch:1 inView:self];
                
                NSInteger positionTouch1 = [self.layoutStrategy itemPositionFromLocation:locationTouch1];
                NSInteger positionTouch2 = [self.layoutStrategy itemPositionFromLocation:locationTouch2];
                
                valid = (!self.isEditing && ([self isInTransformingState] || ((positionTouch1 == positionTouch2) && (positionTouch1 != DCGV_INVALID_POSITION))));
            } else {
                valid = NO;
            }
        }
    } while (NO);
    return valid;
}


#pragma mark - DCGridView - Sorting gestures & logic
- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture {
    do {
        if (self.enableEditOnLongPress && !self.editing) {
            CGPoint locationTouch = [longPressGesture locationInView:self];
            NSInteger position = [self.layoutStrategy itemPositionFromLocation:locationTouch];
            
            if (position != DCGV_INVALID_POSITION) {
                if (!self.editing) {
                    self.editing = YES;
                }
            }
            break;
        }
        
        switch (longPressGesture.state) {
            case UIGestureRecognizerStateBegan:
            {
                if (!_sortMovingItem) {
                    CGPoint location = [longPressGesture locationInView:self];
                    
                    NSInteger position = [self.layoutStrategy itemPositionFromLocation:location];
                    
                    if (position != DCGV_INVALID_POSITION) {
                        [self sortingMoveDidStartAtPoint:location];
                    }
                }
                
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [_sortingPanGesture end];
                
                if (_sortMovingItem) {
                    CGPoint location = [longPressGesture locationInView:self];
                    [self sortingMoveDidStopAtPoint:location];
                }
                
                break;
            }
            default:
                break;
        }
    } while (NO);
}

- (void)sortingPanGestureUpdated:(UIPanGestureRecognizer *)panGesture {
    do {
        switch (panGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                _autoScrollActive = NO;
                break;
            }
            case UIGestureRecognizerStateBegan:
            {
                _autoScrollActive = YES;
                [self sortingAutoScrollMovementCheck];
                
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGPoint translation = [panGesture translationInView:self];
                CGPoint offset = translation;
                CGPoint locationInScroll = [panGesture locationInView:self];
                
                _sortMovingItem.transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
                [self sortingMoveDidContinueToPoint:locationInScroll];
                
                break;
            }
            default:
                break;
        }
    } while (NO);
}

- (void)sortingAutoScrollMovementCheck {
    do {
        if (_sortMovingItem && _autoScrollActive) {
            CGPoint locationInMainView = [_sortingPanGesture locationInView:self];
            locationInMainView = CGPointMake(locationInMainView.x - self.contentOffset.x, locationInMainView.y -self.contentOffset.y);
            
            CGFloat threshhold = _itemSize.height;
            CGPoint offset = self.contentOffset;
            CGPoint locationInScroll = [_sortingPanGesture locationInView:self];
            
            if (locationInMainView.x + threshhold > self.bounds.size.width) {  // Going down
                offset.x += _itemSize.width / 2;
                
                if (offset.x > _maxPossibleContentOffset.x) {
                    offset.x = _maxPossibleContentOffset.x;
                }
            } else if (locationInMainView.x - threshhold <= 0) {  // Going up
                offset.x -= _itemSize.width / 2;
                
                if (offset.x < _minPossibleContentOffset.x)
                {
                    offset.x = _minPossibleContentOffset.x;
                }
            }
            
            if (locationInMainView.y + threshhold > self.bounds.size.height) {  // Going right
                offset.y += _itemSize.height / 2;
                
                if (offset.y > _maxPossibleContentOffset.y) {
                    offset.y = _maxPossibleContentOffset.y;
                }
            } else if (locationInMainView.y - threshhold <= 0) {  // Going left
                offset.y -= _itemSize.height / 2;
                
                if (offset.y < _minPossibleContentOffset.y) {
                    offset.y = _minPossibleContentOffset.y;
                }
            }
            
            if (offset.x != self.contentOffset.x || offset.y != self.contentOffset.y) {
                [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                    self.contentOffset = offset;
                } completion:^(BOOL finished){
                    self.contentOffset = offset;
                    if (_autoScrollActive) {
                        [self sortingMoveDidContinueToPoint:locationInScroll];
                    }
                    [self sortingAutoScrollMovementCheck];
                }];
            } else {
                [self performSelector:@selector(sortingAutoScrollMovementCheck) withObject:nil afterDelay:0.5];
            }
        }
    } while (NO);
}

- (void)sortingMoveDidStartAtPoint:(CGPoint)point {
    do {
        NSInteger position = [self.layoutStrategy itemPositionFromLocation:point];
        
        DCGridViewCell *item = [self cellForItemAtIndex:position];
        
        [self bringSubviewToFront:item];
        _sortMovingItem = item;
        
        CGRect frameInMainView = [self convertRect:_sortMovingItem.frame toView:self.mainSuperView];
        
        [_sortMovingItem removeFromSuperview];
        _sortMovingItem.frame = frameInMainView;
        [self.mainSuperView addSubview:_sortMovingItem];
        
        _sortFuturePosition = (_sortMovingItem.tag - kTagOffset);
        _sortMovingItem.tag = 0;
        
        if ([self.sortingDelegate respondsToSelector:@selector(DCGridView:didStartMovingCell:)]) {
            [self.sortingDelegate DCGridView:self didStartMovingCell:_sortMovingItem];
        }
        
        if ([self.sortingDelegate respondsToSelector:@selector(DCGridView:shouldAllowShakingBehaviorWhenMovingCell:atIndex:)]) {
            [_sortMovingItem shake:[self.sortingDelegate DCGridView:self shouldAllowShakingBehaviorWhenMovingCell:_sortMovingItem atIndex:position]];
        } else {
            [_sortMovingItem shake:YES];
        }
    } while (NO);
}

- (void)sortingMoveDidStopAtPoint:(CGPoint)point {
    do {
        [_sortMovingItem shake:NO];
        
        _sortMovingItem.tag = (_sortFuturePosition + kTagOffset);
        
        CGRect frameInScroll = [self.mainSuperView convertRect:_sortMovingItem.frame toView:self];
        
        [_sortMovingItem removeFromSuperview];
        _sortMovingItem.frame = frameInScroll;
        [self addSubview:_sortMovingItem];
        
        CGPoint newOrigin = [self.layoutStrategy originForItemAtPosition:_sortFuturePosition];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, _itemSize.width, _itemSize.height);
        
        [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:0 animations:^{
            _sortMovingItem.transform = CGAffineTransformIdentity;
            _sortMovingItem.frame = newFrame;
        } completion:^(BOOL finished){
            if ([self.sortingDelegate respondsToSelector:@selector(DCGridView:didEndMovingCell:)]) { [self.sortingDelegate DCGridView:self didEndMovingCell:_sortMovingItem];
            }
            _sortMovingItem = nil;
            _sortFuturePosition = DCGV_INVALID_POSITION;
            
            [self setSubviewsCacheAsInvalid];
        }];
    } while (NO);
}

- (void)sortingMoveDidContinueToPoint:(CGPoint)point {
    do {
        int position = [self.layoutStrategy itemPositionFromLocation:point];
        int tag = (position + kTagOffset);
        
        if (position != DCGV_INVALID_POSITION && position != _sortFuturePosition && position < _numberTotalItems) {
            BOOL positionTaken = NO;
            
            for (UIView *v in [self itemSubviews]) {
                if (v != _sortMovingItem && v.tag == tag) {
                    positionTaken = YES;
                    break;
                }
            }
            
            if (positionTaken) {
                switch (self.style) {
                    case DCGridViewStylePush:
                    {
                        if (position > _sortFuturePosition) {
                            for (UIView *v in [self itemSubviews]) {
                                if ((v.tag == tag || (v.tag < tag && v.tag >= _sortFuturePosition + kTagOffset)) && v != _sortMovingItem) {
                                    v.tag = v.tag - 1;
                                    [self sendSubviewToBack:v];
                                }
                            }
                        } else {
                            for (UIView *v in [self itemSubviews]) {
                                if ((v.tag == tag || (v.tag > tag && v.tag <= _sortFuturePosition + kTagOffset)) && v != _sortMovingItem) {
                                    v.tag = v.tag + 1;
                                    [self sendSubviewToBack:v];
                                }
                            }
                        }
                        
                        [self.sortingDelegate DCGridView:self moveItemAtIndex:_sortFuturePosition toIndex:position];
                        [self relayoutItemsAnimated:YES];
                        
                        break;
                    }
                    case DCGridViewStyleSwap:
                    default:
                    {
                        if (_sortMovingItem) {
                            UIView *v = [self cellForItemAtIndex:position];
                            
                            v.tag = (_sortFuturePosition + kTagOffset);
                            CGPoint origin = [self.layoutStrategy originForItemAtPosition:_sortFuturePosition];
                            
                            [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                                v.frame = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
                            } completion:nil];
                        }
                        
                        [self.sortingDelegate DCGridView:self exchangeItemAtIndex:_sortFuturePosition withItemAtIndex:position];
                        
                        break;
                    }
                }
            }
            
            _sortFuturePosition = position;
        }
    } while (NO);
}

@end
