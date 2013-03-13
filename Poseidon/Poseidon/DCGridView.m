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
    UIPanGestureRecognizer *_dragdropPanGesture;
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
    DCGridViewCell *_dragMovingItem;
    NSInteger _dropFuturePosition;
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

@property (nonatomic, readonly) BOOL itemsSubviewsCacheIsValid;
@property (nonatomic, SAFE_ARC_PROP_STRONG) NSArray *itemSubviewsCache;
@property (atomic) NSInteger firstPositionLoaded;
@property (atomic) NSInteger lastPositionLoaded;

- (void)commonInit;

// Gestures
- (void)dragdropPanGestureUpdated:(UIPanGestureRecognizer *)panGesture;
- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture;
- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture;
- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture;
- (void)pinchGestureUpdated:(UIPinchGestureRecognizer *)pinchGesture;
- (void)rotationGestureUpdated:(UIRotationGestureRecognizer *)rotationGesture;

// DragDrop movement control
- (void)dragdropMoveDidStartAtPoint:(CGPoint)point;
- (void)dragdropMoveDidContinueToPoint:(CGPoint)point;
- (void)dragdropMoveDidStopAtPoint:(CGPoint)point;
- (void)dragdropAutoScrollMovementCheck;

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

@synthesize dragdropDelegate = _dragdropDelegate;
@synthesize dataSource = _dataSource;
@synthesize transformDelegate = _transformDelegate;
@synthesize actionDelegate = _actionDelegate;
@synthesize mainSuperView = _mainSuperView;
@synthesize layoutStrategy = _layoutStrategy;
@synthesize itemSpacing = _itemSpacing;
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
        
        _dragdropPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragdropPanGestureUpdated:)];
        _dragdropPanGesture.delegate = self;
        [self addGestureRecognizer:_dragdropPanGesture];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
        _longPressGesture.numberOfTouchesRequired = 1;
        _longPressGesture.delegate = self;
        _longPressGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_longPressGesture];
        
        ////////////////////////
        // Gesture dependencies
        UIPanGestureRecognizer *panGestureRecognizer = nil;
        if ([self respondsToSelector:@selector(panGestureRecognizer)]) {  // iOS5 only
            panGestureRecognizer = self.panGestureRecognizer;
        } else {
            for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
                if ([gestureRecognizer  isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
                    panGestureRecognizer = (UIPanGestureRecognizer *) gestureRecognizer;
                }
            }
        }
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        [panGestureRecognizer requireGestureRecognizerToFail:_dragdropPanGesture];
        
        self.layoutStrategy = [DCGridViewLayoutStrategyFactory strategyFromType:DCGridViewLayoutVertical];
        
        self.mainSuperView = self;
        self.editing = NO;
        self.itemSpacing = 8;
        self.minimumPressDuration = 0.2;
        self.showFullSizeViewWithAlphaWhenTransforming = YES;
        self.minEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        self.clipsToBounds = NO;
        
        _dropFuturePosition = DCGV_INVALID_POSITION;
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
        
        SAFE_ARC_SUPER_DEALLOC();
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
        [self recomputeSizeAnimated:!(animation & DCGridViewItemAnimation_Null)];
        [self relayoutItemsAnimated:animation & DCGridViewItemAnimation_Fade]; // only supported animation for now
        [self loadRequiredItems];
    } while (NO);
}

- (void)layoutSubviews {
    do {
        [super layoutSubviews];
        
        if (_rotationActive) {
            _rotationActive = NO;
            
            // Updating all the items size
            
            CGSize itemSize = [self.dataSource gridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            
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
                CGSize fullSize = [self.transformDelegate gridView:self sizeInFullSizeForCell:_transformingItem atIndex:position inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                
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
                [self layoutSubviewsWithAnimation:DCGridViewItemAnimation_Null];
            }];
            
            // Fixing the contentOffset when pagging enabled
            
            if (self.pagingEnabled) {
                [self setContentOffset:[self rectForPoint:self.contentOffset inPaggingMode:YES].origin animated:YES];
            }
        } else {
            [self layoutSubviewsWithAnimation:DCGridViewItemAnimation_Null];
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
        
        if ([self.actionDelegate respondsToSelector:@selector(gridView:changedEdit:)]) {
            [self.actionDelegate gridView:self changedEdit:editing];
        }
    } while (NO);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    do {
        if ([self.actionDelegate respondsToSelector:@selector(gridView:processDeleteActionForItemAtIndex:)] &&![self isInTransformingState] && ((self.isEditing && !editing) || (!self.isEditing && editing))) {
            for (DCGridViewCell *cell in [self itemSubviews]) {
                NSInteger index = [self positionForItemSubview:cell];
                if (index != DCGV_INVALID_POSITION) {
                    BOOL allowEdit = editing && [self.dataSource gridView:self canDeleteItemAtIndex:index];
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
            valid = ((self.dragdropDelegate || self.enableEditOnLongPress) && !isScrolling && !self.isEditing);
        } else if (gestureRecognizer == _dragdropPanGesture) {
            valid = (_dragMovingItem != nil && [_longPressGesture hasRecognizedValidGesture]);
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


#pragma mark - DCGridView - DragDrop gestures & logic
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
                if (!_dragMovingItem) {
                    CGPoint location = [longPressGesture locationInView:self];
                    
                    NSInteger position = [self.layoutStrategy itemPositionFromLocation:location];                    
                    
                    if (position != DCGV_INVALID_POSITION) {
                        DCGridViewCell *cell = [self cellForItemAtIndex:position];
                        if ([self.dragdropDelegate dragdropStyle] == DCGridViewDragDropStyle_Customizable) {
                            if ([self.dragdropDelegate respondsToSelector:@selector(gridView:dragdropStateBegin:withGestureRecognizer:)]) {
                                [self.dragdropDelegate gridView:self dragdropStateBegin:cell withGestureRecognizer:longPressGesture];
                                                                
                                _dragMovingItem = cell;
                            }
                        } else {
                            [self dragdropMoveDidStartAtPoint:location];
                        }
                    }
                }
                
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [_dragdropPanGesture end];
                
                if (_dragMovingItem) {
                    CGPoint location = [longPressGesture locationInView:self];
                    if ([self.dragdropDelegate dragdropStyle] == DCGridViewDragDropStyle_Customizable) {
                        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:dragdropStateEnd:withGestureRecognizer:)]) {
                            [self.dragdropDelegate gridView:self dragdropStateEnd:_dragMovingItem withGestureRecognizer:longPressGesture];
                        }
                        
                        _dragMovingItem = nil;
                        _dropFuturePosition = DCGV_INVALID_POSITION;
                        
                        [self setSubviewsCacheAsInvalid];
                    } else {
                        [self dragdropMoveDidStopAtPoint:location];
                    }
                }
                
                break;
            }
            default:
                break;
        }
    } while (NO);
}

- (void)dragdropPanGestureUpdated:(UIPanGestureRecognizer *)panGesture {
    do {
        switch (panGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                if ([self.dragdropDelegate dragdropStyle] == DCGridViewDragDropStyle_Customizable) {
                    ;
                } else {
                    _autoScrollActive = NO;
                }
                break;
            }
            case UIGestureRecognizerStateBegan:
            {
                if ([self.dragdropDelegate dragdropStyle] == DCGridViewDragDropStyle_Customizable) {
                    ;
                } else {
                    _autoScrollActive = YES;
                    [self dragdropAutoScrollMovementCheck];
                }
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (_dragMovingItem) {
                    if ([self.dragdropDelegate dragdropStyle] == DCGridViewDragDropStyle_Customizable) {
                        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:dragdropStateChanged:withGestureRecognizer:)]) {
                            [self.dragdropDelegate gridView:self dragdropStateChanged:_dragMovingItem withGestureRecognizer:panGesture];
                        }
                    } else {
                        CGPoint translation = [panGesture translationInView:self];
                        CGPoint offset = translation;
                        CGPoint locationInScroll = [panGesture locationInView:self];
                        
                        _dragMovingItem.transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
                        [self dragdropMoveDidContinueToPoint:locationInScroll];
                    }
                }
                break;
            }
            default:
                break;
        }
    } while (NO);
}

- (void)dragdropAutoScrollMovementCheck {
    do {
        if (_dragMovingItem && _autoScrollActive) {
            CGPoint locationInMainView = [_dragdropPanGesture locationInView:self];
            locationInMainView = CGPointMake(locationInMainView.x - self.contentOffset.x, locationInMainView.y -self.contentOffset.y);
            
            CGFloat threshhold = _itemSize.height;
            CGPoint offset = self.contentOffset;
            CGPoint locationInScroll = [_dragdropPanGesture locationInView:self];
            
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
                } completion:^(BOOL finished) {
                    self.contentOffset = offset;
                    if (_autoScrollActive) {
                        [self dragdropMoveDidContinueToPoint:locationInScroll];
                    }
                    [self dragdropAutoScrollMovementCheck];
                }];
            } else {
                [self performSelector:@selector(sortingAutoScrollMovementCheck) withObject:nil afterDelay:0.5];
            }
        }
    } while (NO);
}

- (void)dragdropMoveDidStartAtPoint:(CGPoint)point {
    do {
        NSInteger position = [self.layoutStrategy itemPositionFromLocation:point];
        
        DCGridViewCell *item = [self cellForItemAtIndex:position];
        
        [self bringSubviewToFront:item];
        _dragMovingItem = item;
        
        CGRect frameInMainView = [self convertRect:_dragMovingItem.frame toView:self.mainSuperView];
        
        [_dragMovingItem removeFromSuperview];
        _dragMovingItem.frame = frameInMainView;
        [self.mainSuperView addSubview:_dragMovingItem];
        
        _dropFuturePosition = (_dragMovingItem.tag - kTagOffset);
        _dragMovingItem.tag = 0;
        
        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:didStartMovingCell:)]) {
            [self.dragdropDelegate gridView:self didStartMovingCell:_dragMovingItem];
        }
        
        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:shouldAllowShakingBehaviorWhenMovingCell:atIndex:)]) {
            [_dragMovingItem shake:[self.dragdropDelegate gridView:self shouldAllowShakingBehaviorWhenMovingCell:_dragMovingItem atIndex:position]];
        } else {
            [_dragMovingItem shake:YES];
        }
    } while (NO);
}

- (void)dragdropMoveDidStopAtPoint:(CGPoint)point {
    do {
        [_dragMovingItem shake:NO];
        
        _dragMovingItem.tag = (_dropFuturePosition + kTagOffset);
        
        CGRect frameInScroll = [self.mainSuperView convertRect:_dragMovingItem.frame toView:self];
        
        [_dragMovingItem removeFromSuperview];
        _dragMovingItem.frame = frameInScroll;
        [self addSubview:_dragMovingItem];
        
        CGPoint newOrigin = [self.layoutStrategy originForItemAtPosition:_dropFuturePosition];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, _itemSize.width, _itemSize.height);
        
        [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:0 animations:^{
            _dragMovingItem.transform = CGAffineTransformIdentity;
            _dragMovingItem.frame = newFrame;
        } completion:^(BOOL finished) {
            if ([self.dragdropDelegate respondsToSelector:@selector(gridView:didEndMovingCell:)]) { [self.dragdropDelegate gridView:self didEndMovingCell:_dragMovingItem];
            }
            _dragMovingItem = nil;
            _dropFuturePosition = DCGV_INVALID_POSITION;
            
            [self setSubviewsCacheAsInvalid];
        }];
    } while (NO);
}

- (void)dragdropMoveDidContinueToPoint:(CGPoint)point {
    do {
        int position = [self.layoutStrategy itemPositionFromLocation:point];
        int tag = (position + kTagOffset);
        
        if (position != DCGV_INVALID_POSITION && position != _dropFuturePosition && position < _numberTotalItems) {
            BOOL positionTaken = NO;
            
            for (UIView *v in [self itemSubviews]) {
                if (v != _dragMovingItem && v.tag == tag) {
                    positionTaken = YES;
                    break;
                }
            }
            
            if (positionTaken) {
                switch ([self.dragdropDelegate dragdropStyle]) {
                    case DCGridViewDragDropStyle_PushSort:
                    {
                        if (position > _dropFuturePosition) {
                            for (UIView *v in [self itemSubviews]) {
                                if ((v.tag == tag || (v.tag < tag && v.tag >= _dropFuturePosition + kTagOffset)) && v != _dragMovingItem) {
                                    v.tag = v.tag - 1;
                                    [self sendSubviewToBack:v];
                                }
                            }
                        } else {
                            for (UIView *v in [self itemSubviews]) {
                                if ((v.tag == tag || (v.tag > tag && v.tag <= _dropFuturePosition + kTagOffset)) && v != _dragMovingItem) {
                                    v.tag = v.tag + 1;
                                    [self sendSubviewToBack:v];
                                }
                            }
                        }
                        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:moveItemAtIndex:toIndex:)]) {
                            [self.dragdropDelegate gridView:self moveItemAtIndex:_dropFuturePosition toIndex:position];
                        }
                        [self relayoutItemsAnimated:YES];
                        
                        break;
                    }
                    case DCGridViewDragDropStyle_SwapSort:
                    default:
                    {
                        if (_dragMovingItem) {
                            UIView *v = [self cellForItemAtIndex:position];
                            
                            v.tag = (_dropFuturePosition + kTagOffset);
                            CGPoint origin = [self.layoutStrategy originForItemAtPosition:_dropFuturePosition];
                            
                            [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                                v.frame = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
                            } completion:nil];
                        }
                        if ([self.dragdropDelegate respondsToSelector:@selector(gridView:exchangeItemAtIndex:withItemAtIndex:)]) {
                            [self.dragdropDelegate gridView:self exchangeItemAtIndex:_dropFuturePosition withItemAtIndex:position];
                        }
                        break;
                    }
                }
            }
            
            _dropFuturePosition = position;
        }
    } while (NO);
}

#pragma mark - DCGridView - Transformation gestures & logic
- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture {
    do {
        switch (panGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(transformingGestureDidFinish) object:nil];
                [self performSelector:@selector(transformingGestureDidFinish) withObject:nil afterDelay:0.1];
                
                self.scrollEnabled = YES;
                
                break;
            }
            case UIGestureRecognizerStateBegan:
            {
                [self transformingGestureDidBeginWithGesture:panGesture];
                self.scrollEnabled = NO;
                
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (panGesture.numberOfTouches != 2) {
                    [panGesture end];
                }
                
                CGPoint translate = [panGesture translationInView:self];
                [_transformingItem.contentView setCenter:CGPointMake(_transformingItem.contentView.center.x + translate.x, _transformingItem.contentView.center.y + translate.y)];
                [panGesture setTranslation:CGPointZero inView:self];
                
                break;
            }
            default:
            {
            }
        }
    } while (NO);
}

- (void)pinchGestureUpdated:(UIPinchGestureRecognizer *)pinchGesture {
    do {
        switch (pinchGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(transformingGestureDidFinish) object:nil];
                [self performSelector:@selector(transformingGestureDidFinish) withObject:nil afterDelay:0.1];
                
                break;
            }
            case UIGestureRecognizerStateBegan:
            {
                [self transformingGestureDidBeginWithGesture:pinchGesture];
            }
            case UIGestureRecognizerStateChanged:
            {
                CGFloat currentScale = [[_transformingItem.contentView.layer valueForKeyPath:@"transform.scale"] floatValue];
                
                CGFloat scale = 1 - (_lastScale - [_pinchGesture scale]);
                
                //todo: compute these scale factors dynamically based on ratio of thumbnail/fullscreen sizes
                const CGFloat kMaxScale = 3;
                const CGFloat kMinScale = 0.5;
                
                scale = MIN(scale, kMaxScale / currentScale);
                scale = MAX(scale, kMinScale / currentScale);
                
                if (scale >= kMinScale && scale <= kMaxScale) {
                    CGAffineTransform currentTransform = [_transformingItem.contentView transform];
                    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
                    _transformingItem.contentView.transform = newTransform;
                    
                    _lastScale = [_pinchGesture scale];
                    
                    currentScale += scale;
                    
                    CGFloat alpha = 1 - (kMaxScale - currentScale);
                    alpha = MAX(0, alpha);
                    alpha = MIN(1, alpha);
                    
                    if (self.showFullSizeViewWithAlphaWhenTransforming && currentScale >= 1.5) {
                        [_transformingItem stepToFullsizeWithAlpha:alpha];
                    }
                    
                    _transformingItem.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:MIN(alpha, 0.9)];
                }
                
                break;
            }
            default:
            {
            }
        }
    } while (NO);
}

- (void)rotationGestureUpdated:(UIRotationGestureRecognizer *)rotationGesture {
    do {
        switch (rotationGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(transformingGestureDidFinish) object:nil];
                [self performSelector:@selector(transformingGestureDidFinish) withObject:nil afterDelay:0.1];
                
                break;
            }
            case UIGestureRecognizerStateBegan:
            {
                [self transformingGestureDidBeginWithGesture:rotationGesture];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGFloat rotation = [rotationGesture rotation] - _lastRotation;
                CGAffineTransform currentTransform = [_transformingItem.contentView transform];
                CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
                _transformingItem.contentView.transform = newTransform;
                _lastRotation = [rotationGesture rotation];
                
                break;
            }
            default:
            {
            }
        }
    } while (NO);
}

- (void)transformingGestureDidBeginWithGesture:(UIGestureRecognizer *)gesture {
    do {
        _inFullSizeMode = NO;
        
        if (_inTransformingState && [gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            _pinchGesture.scale = 2.5;
        }
        
        if (_inTransformingState) {
            _inTransformingState = NO;
            
            CGPoint center = _transformingItem.fullSizeView.center;
            
            [_transformingItem switchToFullSizeMode:NO];
            CGAffineTransform newTransform = CGAffineTransformMakeScale(2.5, 2.5);
            _transformingItem.contentView.transform = newTransform;
            _transformingItem.contentView.center = center;
        } else if (!_transformingItem) {
            CGPoint locationTouch = [gesture locationOfTouch:0 inView:self];
            NSInteger positionTouch = [self.layoutStrategy itemPositionFromLocation:locationTouch];
            _transformingItem = [self cellForItemAtIndex:positionTouch];
            
            CGRect frameInMainView = [self convertRect:_transformingItem.frame toView:self.mainSuperView];
            
            [_transformingItem removeFromSuperview];
            _transformingItem.frame = self.mainSuperView.bounds;
            _transformingItem.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _transformingItem.contentView.frame = frameInMainView;
            [self.mainSuperView addSubview:_transformingItem];
            [self.mainSuperView bringSubviewToFront:_transformingItem];
            
            _transformingItem.fullSize = [self.transformDelegate gridView:self sizeInFullSizeForCell:_transformingItem atIndex:positionTouch inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            _transformingItem.fullSizeView = [self.transformDelegate gridView:self fullSizeViewForCell:_transformingItem atIndex:positionTouch];
            
            if ([self.transformDelegate respondsToSelector:@selector(gridView:didStartTransformingCell:)]) {
                [self.transformDelegate gridView:self didStartTransformingCell:_transformingItem];
            }
        }
    } while (NO);
}

- (BOOL)isInTransformingState {
    return _transformingItem != nil;
}

- (void)transformingGestureDidFinish {
    do {
        if ([self isInTransformingState]) {
            if (_lastScale > 2 && !_inTransformingState) {
                _lastRotation = 0;
                _lastScale = 1;
                
                [self bringSubviewToFront:_transformingItem];
                
                CGFloat rotationValue = atan2f(_transformingItem.contentView.transform.b, _transformingItem.contentView.transform.a);
                
                _transformingItem.contentView.transform = CGAffineTransformIdentity;
                
                [_transformingItem switchToFullSizeMode:YES];
                _transformingItem.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.9];
                
                _transformingItem.fullSizeView.transform =  CGAffineTransformMakeRotation(rotationValue);
                
                [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                    _transformingItem.fullSizeView.transform = CGAffineTransformIdentity;
                } completion:nil];
                
                _inTransformingState = YES;
                _inFullSizeMode = YES;
                
                if ([self.transformDelegate respondsToSelector:@selector(gridView:didEnterFullSizeForCell:)]) {
                    [self.transformDelegate gridView:self didEnterFullSizeForCell:_transformingItem];
                }
                
                // Transfer the gestures on the fullscreen to make is they are accessible (depends on self.mainSuperView)
                [_transformingItem.fullSizeView addGestureRecognizer:_pinchGesture];
                [_transformingItem.fullSizeView addGestureRecognizer:_rotationGesture];
                [_transformingItem.fullSizeView addGestureRecognizer:_panGesture];
            } else if (!_inTransformingState) {
                _lastRotation = 0;
                _lastScale = 1.0;
                
                DCGridViewCell *transformingView = _transformingItem;
                _transformingItem = nil;
                
                NSInteger position = [self positionForItemSubview:transformingView];
                CGPoint origin = [self.layoutStrategy originForItemAtPosition:position];
                
                CGRect finalFrameInScroll = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
                CGRect finalFrameInSuperview = [self convertRect:finalFrameInScroll toView:self.mainSuperView];
                
                [transformingView switchToFullSizeMode:NO];
                transformingView.autoresizingMask = UIViewAutoresizingNone;
                
                [UIView animateWithDuration: kDefaultAnimationDuration delay:0 options: kDefaultAnimationOptions animations:^{
                    transformingView.contentView.transform = CGAffineTransformIdentity;
                    transformingView.contentView.frame = finalFrameInSuperview;
                    transformingView.backgroundColor = [UIColor clearColor];
                } completion:^(BOOL finished) {
                    [transformingView removeFromSuperview];
                    transformingView.frame = finalFrameInScroll;
                    transformingView.contentView.frame = transformingView.bounds;
                    [self addSubview:transformingView];
                    
                    transformingView.fullSizeView = nil;
                    _inFullSizeMode = NO;
                    
                    if ([self.transformDelegate respondsToSelector:@selector(gridView:didEndTransformingCell:)]) {
                        [self.transformDelegate gridView:self didEndTransformingCell:transformingView];
                    }
                    
                    // Transfer the gestures back
                    [self addGestureRecognizer:_pinchGesture];
                    [self addGestureRecognizer:_rotationGesture];
                    [self addGestureRecognizer:_panGesture];
                }];
            }
        }
    } while (NO);
}

#pragma mark - DCGridView - Tap gesture
- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture {
    do {
        CGPoint locationTouch = [_tapGesture locationInView:self];
        NSInteger position = [self.layoutStrategy itemPositionFromLocation:locationTouch];
        
        if (position != DCGV_INVALID_POSITION) {
            if (!self.editing) {
                [self cellForItemAtIndex:position].highlighted = NO;
                [self.actionDelegate gridView:self didTapOnItemAtIndex:position];
            }
        } else {
            if([self.actionDelegate respondsToSelector:@selector(gridViewDidTapOnEmptySpace:)]) {
                [self.actionDelegate gridViewDidTapOnEmptySpace:self];
            }
            
            if (self.disableEditOnEmptySpaceTap) {
                self.editing = NO;
            }
        }
    } while (NO);
}

#pragma mark - DCGridView - private methods
//////////////////////////////////////////////////////////////

- (void)setSubviewsCacheAsInvalid {
    _itemsSubviewsCacheIsValid = NO;
}

- (DCGridViewCell *)newItemSubViewForPosition:(NSInteger)position {
    DCGridViewCell *cell = nil;
    do {
        cell = [self.dataSource gridView:self cellForItemAtIndex:position];
        CGPoint origin = [self.layoutStrategy originForItemAtPosition:position];
        CGRect frame = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
        
        // To make sure the frame is not animated
        [self applyWithoutAnimation:^{
            cell.frame = frame;
            cell.contentView.frame = cell.bounds;
        }];
        
        cell.tag = position + kTagOffset;
        BOOL canEdit = self.editing && [self.dataSource gridView:self canDeleteItemAtIndex:position];
        [cell setEditing:canEdit animated:NO];
        
        __SAFE_ARC_PROP_WEAK DCGridView *weakSelf = self;
        cell.deleteBlock = ^(DCGridViewCell *aCell) {
            NSInteger index = [weakSelf positionForItemSubview:aCell];
            if (index != DCGV_INVALID_POSITION) {
                BOOL canDelete = YES;
                if ([weakSelf.dataSource respondsToSelector:@selector(gridView:canDeleteItemAtIndex:)]) {
                    canDelete = [weakSelf.dataSource gridView:weakSelf canDeleteItemAtIndex:index];
                }
                
                if (canDelete && [weakSelf.actionDelegate respondsToSelector:@selector(gridView:processDeleteActionForItemAtIndex:)]) {
                    [weakSelf.actionDelegate gridView:weakSelf processDeleteActionForItemAtIndex:index];
                }
            }
        };
    } while (NO);
    return cell;
}

- (NSArray *)itemSubviews {
    NSArray *subviews = nil;
    do {
        if (self.itemsSubviewsCacheIsValid) {
            subviews = [self.itemSubviewsCache copy];
        } else {
            @synchronized(self) {
                NSMutableArray *itemSubViews = [[NSMutableArray alloc] initWithCapacity:_numberTotalItems];
                
                for (UIView *view in [self subviews]) {
                    if ([view isKindOfClass:[DCGridViewCell class]]) {
                        [itemSubViews addObject:view];
                    }
                }
               
                self.itemSubviewsCache = itemSubViews;
                subviews = [itemSubViews copy];
                SAFE_ARC_SAFERELEASE(itemSubViews);
                _itemsSubviewsCacheIsValid = YES;
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE(subviews);
    return subviews;
}

- (DCGridViewCell *)cellForItemAtIndex:(NSInteger)position {
    DCGridViewCell *view = nil;
    do {
        for (DCGridViewCell *cell in [self itemSubviews]) {
            if (cell.tag == position + kTagOffset) {
                view = cell;
                break;
            }
        }
    } while (NO);
    return view;
}

- (NSInteger)positionForItemSubview:(DCGridViewCell *)view {
    return view.tag >= (kTagOffset ? (view.tag - kTagOffset) : DCGV_INVALID_POSITION);
}

- (void)recomputeSizeAnimated:(BOOL)animated {
    do {
        [self.layoutStrategy setupItemSize:_itemSize andItemSpacing:self.itemSpacing withMinEdgeInsets:self.minEdgeInsets andCenteredGrid:self.centerGrid];
        [self.layoutStrategy rebaseWithItemCount:_numberTotalItems insideOfBounds:self.bounds];
        
        CGSize contentSize = [self.layoutStrategy contentSize];
        
        _minPossibleContentOffset = CGPointMake(0, 0);
        _maxPossibleContentOffset = CGPointMake(contentSize.width - self.bounds.size.width + self.contentInset.right, contentSize.height - self.bounds.size.height + self.contentInset.bottom);
        
        BOOL shouldUpdateScrollviewContentSize = !CGSizeEqualToSize(self.contentSize, contentSize);
        
        if (shouldUpdateScrollviewContentSize) {
            if (animated) {
                [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                    self.contentSize = contentSize;
                } completion:nil];
            } else {
                self.contentSize = contentSize;
            }
        }
    } while (NO);
}

- (void)relayoutItemsAnimated:(BOOL)animated {
    do {
        void (^layoutBlock)(void) = ^{
            for (UIView *view in [self itemSubviews]) {
                if (view != _dragMovingItem && view != _transformingItem) {
                    NSInteger index = view.tag - kTagOffset;
                    CGPoint origin = [self.layoutStrategy originForItemAtPosition:index];
                    CGRect newFrame = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
                    
                    // IF statement added for performance reasons (Time Profiling in instruments)
                    if (!CGRectEqualToRect(newFrame, view.frame)) {
                        view.frame = newFrame;
                    }
                }
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                layoutBlock();
            } completion:nil];
        } else {
            layoutBlock();
        }
    } while (NO);
}

- (CGRect)rectForPoint:(CGPoint)point inPaggingMode:(BOOL)pagging {
    CGRect targetRect = CGRectZero;
    do {
        if (self.pagingEnabled) {
            CGPoint originScroll = CGPointZero;
            
            CGSize pageSize = CGSizeMake(self.bounds.size.width - self.contentInset.left - self.contentInset.right, self.bounds.size.height - self.contentInset.top - self.contentInset.bottom);
            
            CGFloat pageX = ceilf(point.x / pageSize.width);
            CGFloat pageY = ceilf(point.y / pageSize.height);
            
            originScroll = CGPointMake(pageX * pageSize.width, pageY *pageSize.height);
            
            /*
             while (originScroll.x + pageSize.width < point.x)
             {
             originScroll.x += pageSize.width;
             }
             
             while (originScroll.y + pageSize.height < point.y)
             {
             originScroll.y += pageSize.height;
             }
             */
            targetRect = CGRectMake(originScroll.x, originScroll.y, pageSize.width, pageSize.height);
        } else {
            targetRect = CGRectMake(point.x, point.y, _itemSize.width, _itemSize.height);
        }
    } while (NO);
    return targetRect;
}

#pragma mark - DCGridView - loading/destroying items & reusing cells
- (void)loadRequiredItems {
    do {
        NSRange rangeOfPositions = [self.layoutStrategy rangeOfPositionsInBoundsFromOffset: self.contentOffset];
        NSRange loadedPositionsRange = NSMakeRange(self.firstPositionLoaded, self.lastPositionLoaded - self.firstPositionLoaded);
        
        // calculate new position range
        self.firstPositionLoaded = (self.firstPositionLoaded == DCGV_INVALID_POSITION ? rangeOfPositions.location : MIN(self.firstPositionLoaded, (NSInteger)rangeOfPositions.location));
        self.lastPositionLoaded = (self.lastPositionLoaded == DCGV_INVALID_POSITION ? NSMaxRange(rangeOfPositions) : MAX(self.lastPositionLoaded, (NSInteger)(rangeOfPositions.length + rangeOfPositions.location)));
        
        // remove now invisible items
        [self setSubviewsCacheAsInvalid];
        [self cleanupUnseenItems];
        
        // add new cells
        BOOL forceLoad = ((self.firstPositionLoaded == DCGV_INVALID_POSITION) || (self.lastPositionLoaded == DCGV_INVALID_POSITION));
        NSInteger positionToLoad;
        for (NSUInteger idx = 0; idx < rangeOfPositions.length; ++idx) {
            positionToLoad = idx + rangeOfPositions.location;
            
            if ((forceLoad || !NSLocationInRange(positionToLoad, loadedPositionsRange)) && positionToLoad < _numberTotalItems) {
                if (![self cellForItemAtIndex:positionToLoad]) {
                    DCGridViewCell *cell = [self newItemSubViewForPosition:positionToLoad];
                    if (cell) {
                        [self addSubview:cell];
                    }
                }
            }
        }
    } while (NO);
}


- (void)cleanupUnseenItems {
    do {
        NSRange rangeOfPositions = [self.layoutStrategy rangeOfPositionsInBoundsFromOffset:self.contentOffset];
        DCGridViewCell *cell = nil;
        
        if ((NSInteger)rangeOfPositions.location > self.firstPositionLoaded) {
            for (NSInteger idx = self.firstPositionLoaded; idx < (NSInteger)rangeOfPositions.location; ++idx) {
                cell = [self cellForItemAtIndex:idx];
                if (cell) {
                    [self queueReusableCell:cell];
                    [cell removeFromSuperview];
                }
            }
            
            self.firstPositionLoaded = rangeOfPositions.location;
            [self setSubviewsCacheAsInvalid];
        }
        
        if ((NSInteger)NSMaxRange(rangeOfPositions) < self.lastPositionLoaded) {
            for (NSInteger idx = NSMaxRange(rangeOfPositions); idx <= self.lastPositionLoaded; ++idx) {
                cell = [self cellForItemAtIndex:idx];
                if (cell) {
                    [self queueReusableCell:cell];
                    [cell removeFromSuperview];
                }
            }
            
            self.lastPositionLoaded = NSMaxRange(rangeOfPositions);
            [self setSubviewsCacheAsInvalid];
        }
    } while (NO);
}

- (void)queueReusableCell:(DCGridViewCell *)cell {
    do {
        if (cell) {
            [cell prepareForReuse];
            cell.alpha = 1;
            cell.backgroundColor = [UIColor clearColor];
            [_reusableCells addObject:cell];
        }
    } while (NO);
}

- (DCGridViewCell *)dequeueReusableCell {
    DCGridViewCell *cell = nil;
    do {
        cell = [_reusableCells anyObject];
        
        if (cell) {
            SAFE_ARC_RETAIN(cell);
            [_reusableCells removeObject:cell];
            SAFE_ARC_AUTORELEASE(cell);
        }
    } while (NO);
    return cell;
}

- (DCGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    DCGridViewCell *cell = nil;
    do {
        for (DCGridViewCell *reusableCell in [_reusableCells allObjects]) {
            if ([reusableCell.reuseIdentifier isEqualToString:identifier]) {
                cell = reusableCell;
                break;
            }
        }
        
        if (cell) {
            [_reusableCells removeObject:cell];
        }
    } while (NO);
    return cell;
}

#pragma mark - DCGridView - public methods
- (void)reloadData {
    do {
        CGPoint previousContentOffset = self.contentOffset;
        
        [[self itemSubviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            if ([obj isKindOfClass:[DCGridViewCell class]]) {
                [(UIView *)obj removeFromSuperview];
                [self queueReusableCell:(DCGridViewCell *)obj];
            }
        }];
        
        self.firstPositionLoaded = DCGV_INVALID_POSITION;
        self.lastPositionLoaded  = DCGV_INVALID_POSITION;
        
        [self setSubviewsCacheAsInvalid];
        
        NSUInteger numberItems = [self.dataSource numberOfItemsInGridView:self];
        _itemSize = [self.dataSource gridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        _numberTotalItems = numberItems;
        
        [self recomputeSizeAnimated:NO];
        
        CGPoint newContentOffset = CGPointMake(MIN(_maxPossibleContentOffset.x, previousContentOffset.x), MIN(_maxPossibleContentOffset.y, previousContentOffset.y));
        newContentOffset = CGPointMake(MAX(newContentOffset.x, _minPossibleContentOffset.x), MAX(newContentOffset.y, _minPossibleContentOffset.y));
        
        self.contentOffset = newContentOffset;
        
        [self loadRequiredItems];
        
        [self setSubviewsCacheAsInvalid];
        [self setNeedsLayout];
    } while (NO);
}

- (void)reloadObjectAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self reloadObjectAtIndex:index withAnimation:(animated ? DCGridViewItemAnimation_Scroll : DCGridViewItemAnimation_Null)];
}

- (void)reloadObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation {
    do {
        NSAssert((index >= 0 && index < _numberTotalItems), @"Invalid index");
        
        UIView *currentView = [self cellForItemAtIndex:index];
        
        DCGridViewCell *cell = [self newItemSubViewForPosition:index];
        CGPoint origin = [self.layoutStrategy originForItemAtPosition:index];
        cell.frame = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
        cell.alpha = 0;
        [self addSubview:cell];
        
        currentView.tag = kTagOffset - 1;
        BOOL shouldScroll = animation & DCGridViewItemAnimation_Scroll;
        BOOL animate = animation & DCGridViewItemAnimation_Fade;
        [UIView animateWithDuration:(animate ? kDefaultAnimationDuration : 0.f) delay:0.f options:kDefaultAnimationOptions animations:^{
            if (shouldScroll) {
                [self scrollToObjectAtIndex:index atScrollPosition:DCGridViewScrollPosition_Null animated:NO];
            }
            currentView.alpha = 0;
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
        }];
        
        [self setSubviewsCacheAsInvalid];
    } while (NO);
}

- (void)scrollToObjectAtIndex:(NSInteger)index atScrollPosition:(DCGridViewScrollPosition)scrollPosition animated:(BOOL)animated {
    do {
        index = MAX(0, index);
        index = MIN(index, _numberTotalItems);
        
        CGPoint origin = [self.layoutStrategy originForItemAtPosition:index];
        CGRect targetRect = [self rectForPoint:origin inPaggingMode:self.pagingEnabled];
        
        if (!self.pagingEnabled) {
            CGRect gridRect = CGRectMake(origin.x, origin.y, _itemSize.width, _itemSize.height);
            switch (scrollPosition) {
                case DCGridViewScrollPosition_Null:
                default:
                    targetRect = gridRect;  // no special coordinate handling
                    break;
                    
                case DCGridViewScrollPosition_Top:
                    targetRect.origin.y = gridRect.origin.y;  // set target y origin to cell's y origin
                    break;
                    
                case DCGridViewScrollPosition_Middle:
                    targetRect.origin.y = MAX(gridRect.origin.y - (CGFloat)ceilf((targetRect.size.height - gridRect.size.height) * 0.5), 0.0);
                    break;
                    
                case DCGridViewScrollPosition_Bottom:
                    targetRect.origin.y = MAX((CGFloat)floorf(gridRect.origin.y - (targetRect.size.height - gridRect.size.height)), 0.0);
                    break;
            }
        }
        
        // Better performance animating ourselves instead of using animated:YES in scrollRectToVisible
        [UIView animateWithDuration:(animated ? kDefaultAnimationDuration : 0) delay:0 options:kDefaultAnimationOptions animations:^{
            [self scrollRectToVisible:targetRect animated:NO];
        } completion:^(BOOL finished) {
        }];
    } while (NO);
}

- (void)insertObjectAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self insertObjectAtIndex:index withAnimation:(animated ? DCGridViewItemAnimation_Scroll : DCGridViewItemAnimation_Null)];
}

- (void)insertObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation {
    do {
        NSAssert((index >= 0 && index <= _numberTotalItems), @"Invalid index specified");
        
        DCGridViewCell *cell = nil;
        if (index >= self.firstPositionLoaded && index <= self.lastPositionLoaded) {
            cell = [self newItemSubViewForPosition:index];
            for (int idx = _numberTotalItems - 1; idx >= index; --idx) {
                UIView *oldView = [self cellForItemAtIndex:idx];
                oldView.tag = oldView.tag + 1;
            }
            
            if (animation & DCGridViewItemAnimation_Fade) {
                cell.alpha = 0;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDelay:kDefaultAnimationDuration];
                [UIView setAnimationDuration:kDefaultAnimationDuration];
                cell.alpha = 1.0;
                [UIView commitAnimations];
            }
            [self addSubview:cell];
        }
        
        ++_numberTotalItems;
        [self recomputeSizeAnimated:!(animation & DCGridViewItemAnimation_Null)];
        
        BOOL shouldScroll = (animation & DCGridViewItemAnimation_Scroll);
        if (shouldScroll) {
            [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
                [self scrollToObjectAtIndex:index atScrollPosition:DCGridViewScrollPosition_Null animated:NO];
            } completion:^(BOOL finished) {
                [self layoutSubviewsWithAnimation:animation];
            }];
        } else {
            [self layoutSubviewsWithAnimation:animation];
        }
        
        [self setSubviewsCacheAsInvalid];
    } while (NO);
}

- (void)removeObjectAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self removeObjectAtIndex:index withAnimation:DCGridViewItemAnimation_Null];
}

- (void)removeObjectAtIndex:(NSInteger)index withAnimation:(DCGridViewItemAnimation)animation {
    do {
        NSAssert((index >= 0 && index < _numberTotalItems), @"Invalid index specified");
        
        DCGridViewCell *cell = [self cellForItemAtIndex:index];
        
        for (int idx = index + 1; idx < _numberTotalItems; ++idx) {
            DCGridViewCell *oldView = [self cellForItemAtIndex:idx];
            oldView.tag = oldView.tag - 1;
        }
        
        cell.tag = kTagOffset - 1;
        --_numberTotalItems;
        
        BOOL shouldScroll = animation & DCGridViewItemAnimation_Scroll;
        BOOL animate = animation & DCGridViewItemAnimation_Fade;
        [UIView animateWithDuration:(animate ? kDefaultAnimationDuration : 0.f) delay:0.f options:kDefaultAnimationOptions animations:^{
            cell.contentView.alpha = 0.3f;
            cell.alpha = 0.f;
            
            if (shouldScroll) {
                [self scrollToObjectAtIndex:index atScrollPosition:DCGridViewScrollPosition_Null animated:NO];
            }
            [self recomputeSizeAnimated:!(animation & DCGridViewScrollPosition_Null)];
        } completion:^(BOOL finished) {
            cell.contentView.alpha = 1.f;
            [self queueReusableCell:cell];
            [cell removeFromSuperview];
            
            self.firstPositionLoaded = self.lastPositionLoaded = DCGV_INVALID_POSITION;
            [self loadRequiredItems];
            [self relayoutItemsAnimated:animate];
        }];
        
        [self setSubviewsCacheAsInvalid];
    } while (NO);
}

- (void)swapObjectAtIndex:(NSInteger)index1 withObjectAtIndex:(NSInteger)index2 animated:(BOOL)animated {
    [self swapObjectAtIndex:index1 withObjectAtIndex:index2 withAnimation:(animated ? DCGridViewItemAnimation_Scroll : DCGridViewItemAnimation_Null)];
}

- (void)swapObjectAtIndex:(NSInteger)index1 withObjectAtIndex:(NSInteger)index2 withAnimation:(DCGridViewItemAnimation)animation {
    do {
        NSAssert((index1 >= 0 && index1 < _numberTotalItems), @"Invalid index1 specified");
        NSAssert((index2 >= 0 && index2 < _numberTotalItems), @"Invalid index2 specified");
        
        DCGridViewCell *view1 = [self cellForItemAtIndex:index1];
        DCGridViewCell *view2 = [self cellForItemAtIndex:index2];
        
        view1.tag = index2 + kTagOffset;
        view2.tag = index1 + kTagOffset;
        
        CGPoint view1Origin = [self.layoutStrategy originForItemAtPosition:index2];
        CGPoint view2Origin = [self.layoutStrategy originForItemAtPosition:index1];
        
        view1.frame = CGRectMake(view1Origin.x, view1Origin.y, _itemSize.width, _itemSize.height);
        view2.frame = CGRectMake(view2Origin.x, view2Origin.y, _itemSize.width, _itemSize.height);
        
        
        CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.contentSize.width, self.contentSize.height);
        
        // Better performance animating ourselves instead of using animated:YES in scrollRectToVisible
        BOOL shouldScroll = animation & DCGridViewItemAnimation_Scroll;
        [UIView animateWithDuration:kDefaultAnimationDuration delay:0 options:kDefaultAnimationOptions animations:^{
            if (shouldScroll) {
                if (!CGRectIntersectsRect(view2.frame, visibleRect)) {
                    [self scrollToObjectAtIndex:index1 atScrollPosition:DCGridViewScrollPosition_Null animated:NO];
                } else if (!CGRectIntersectsRect(view1.frame, visibleRect)) {
                    [self scrollToObjectAtIndex:index2 atScrollPosition:DCGridViewScrollPosition_Null animated:NO];
                }
            }
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    } while (NO);
}

#pragma mark - DCGridView - depracated public methods
- (UIScrollView *)scrollView {
    return self;
}


@end
