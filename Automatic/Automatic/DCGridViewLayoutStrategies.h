//
//  DCGridViewLayoutStrategies.h
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

#define DCGV_INVALID_POSITION (-1)

@protocol DCGridViewLayoutStrategy;

typedef enum {
    DCGridViewLayoutVertical = 0,
    DCGridViewLayoutHorizontal,
    DCGridViewLayoutHorizontalPagedLeftToRight,
    DCGridViewLayoutHorizontalPagedTopToBottom,
} DCGridViewLayoutStrategyType;


#pragma mark - interface DCGridViewLayoutStrategyFactory : NSObject
@interface DCGridViewLayoutStrategyFactory : NSObject {
}

+ (id<DCGridViewLayoutStrategy>)strategyFromType:(DCGridViewLayoutStrategyType)type;

@end


#pragma mark - protocol DCGridViewLayoutStrategy <NSObject>
@protocol DCGridViewLayoutStrategy <NSObject>

+ (BOOL)requiresEnablingPaging;

- (DCGridViewLayoutStrategyType)type;

// Setup
- (void)setupItemSize:(CGSize)itemSize andItemSpacing:(NSInteger)spacing withMinEdgeInsets:(UIEdgeInsets)edgeInsets andCenteredGrid:(BOOL)centered;

// Recomputing
- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds;

// Fetching the results
- (CGSize)contentSize;
- (CGPoint)originForItemAtPosition:(NSInteger)position;
- (NSInteger)itemPositionFromLocation:(CGPoint)location;

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset;

@end


#pragma mark - interface DCGridViewLayoutStrategyBase : NSObject
@interface DCGridViewLayoutStrategyBase : NSObject {
@protected
    // All of these vars should be set in the init method
    DCGridViewLayoutStrategyType _type;
    
    // All of these vars should be set in the setup method of the child class
    CGSize _itemSize;
    NSInteger _itemSpacing;
    UIEdgeInsets _minEdgeInsets;
    BOOL _centeredGrid;
    
    // All of these vars should be set in the rebase method of the child class
    NSInteger _itemCount;
    UIEdgeInsets _edgeInsets;
    CGRect _gridBounds;
    CGSize _contentSize;
}

@property(nonatomic, readonly) DCGridViewLayoutStrategyType type;

@property(nonatomic, readonly) CGSize itemSize;
@property(nonatomic, readonly) NSInteger itemSpacing;
@property(nonatomic, readonly) UIEdgeInsets minEdgeInsets;
@property(nonatomic, readonly) BOOL centeredGrid;

@property(nonatomic, readonly) NSInteger itemCount;
@property(nonatomic, readonly) UIEdgeInsets edgeInsets;
@property(nonatomic, readonly) CGRect gridBounds;
@property(nonatomic, readonly) CGSize contentSize;

// Protocol methods implemented in base class
- (void)setupItemSize:(CGSize)itemSize andItemSpacing:(NSInteger)spacing withMinEdgeInsets:(UIEdgeInsets)edgeInsets andCenteredGrid:(BOOL)centered;

// Helpers
- (void)setEdgeAndContentSizeFromAbsoluteContentSize:(CGSize)actualContentSize;

@end

#pragma mark - interface DCGridViewLayoutVerticalStrategy : DCGridViewLayoutStrategyBase <DCGridViewLayoutStrategy>
@interface DCGridViewLayoutVerticalStrategy : DCGridViewLayoutStrategyBase <DCGridViewLayoutStrategy> {
@protected
    NSInteger _numberOfItemsPerRow;
}

@property(nonatomic, readonly) NSInteger numberOfItemsPerRow;

@end


#pragma mark - interface DCGridViewLayoutHorizontalStrategy : DCGridViewLayoutStrategyBase <DCGridViewLayoutStrategy>
@interface DCGridViewLayoutHorizontalStrategy : DCGridViewLayoutStrategyBase <DCGridViewLayoutStrategy> {
@protected
    NSInteger _numberOfItemsPerColumn;
}

@property (nonatomic, readonly) NSInteger numberOfItemsPerColumn;

@end


#pragma mark - interface DCGridViewLayoutHorizontalPagedStrategy : DCGridViewLayoutHorizontalStrategy
@interface DCGridViewLayoutHorizontalPagedStrategy : DCGridViewLayoutHorizontalStrategy {
@protected
    NSInteger _numberOfItemsPerRow;
    NSInteger _numberOfItemsPerPage;
    NSInteger _numberOfPages;
}

@property (nonatomic, readonly) NSInteger numberOfItemsPerRow;
@property (nonatomic, readonly) NSInteger numberOfItemsPerPage;
@property (nonatomic, readonly) NSInteger numberOfPages;

// Only these 3 methods have be reimplemented by child classes to change the LTR and TTB kind of behavior
- (NSInteger)positionForItemAtColumn:(NSInteger)column row:(NSInteger)row page:(NSInteger)page;
- (NSInteger)columnForItemAtPosition:(NSInteger)position;
- (NSInteger)rowForItemAtPosition:(NSInteger)position;

@end


#pragma mark - interface DCGridViewLayoutHorizontalPagedL2RStrategy : DCGridViewLayoutHorizontalPagedStrategy
@interface DCGridViewLayoutHorizontalPagedL2RStrategy : DCGridViewLayoutHorizontalPagedStrategy

@end


#pragma mark - interface DCGridViewLayoutHorizontalPagedT2BStrategy : DCGridViewLayoutHorizontalPagedStrategy
@interface DCGridViewLayoutHorizontalPagedT2BStrategy : DCGridViewLayoutHorizontalPagedStrategy

@end

