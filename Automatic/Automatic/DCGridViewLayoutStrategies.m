//
//  DCGridViewLayoutStrategies.m
//  Automatic
//
//  Created by Chen XiaoLiang on 12-12-24.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "DCGridViewLayoutStrategies.h"


#pragma mark - implementation DCGridViewLayoutStrategyFactory
@implementation DCGridViewLayoutStrategyFactory

+ (id<DCGridViewLayoutStrategy>)strategyFromType:(DCGridViewLayoutStrategyType)type {
    id<DCGridViewLayoutStrategy> strategy = nil;
    do {
        switch (type) {
            case DCGridViewLayoutVertical:
                strategy = [[DCGridViewLayoutVerticalStrategy alloc] init];
                break;
            case DCGridViewLayoutHorizontal:
                strategy = [[DCGridViewLayoutHorizontalStrategy alloc] init];
                break;
            case DCGridViewLayoutHorizontalPagedLeftToRight:
                strategy = [[DCGridViewLayoutHorizontalPagedL2RStrategy alloc] init];
                break;
            case DCGridViewLayoutHorizontalPagedTopToBottom:
                strategy = [[DCGridViewLayoutHorizontalPagedT2BStrategy alloc] init];
                break;
        }
    } while (NO);
    return strategy;
}

@end


#pragma mark - implementation DCGridViewLayoutStrategyBase
@implementation DCGridViewLayoutStrategyBase

@synthesize type          = _type;

@synthesize itemSize      = _itemSize;
@synthesize itemSpacing   = _itemSpacing;
@synthesize minEdgeInsets = _minEdgeInsets;
@synthesize centeredGrid  = _centeredGrid;

@synthesize itemCount     = _itemCount;
@synthesize edgeInsets    = _edgeInsets;
@synthesize gridBounds    = _gridBounds;
@synthesize contentSize   = _contentSize;


- (void)setupItemSize:(CGSize)itemSize andItemSpacing:(NSInteger)spacing withMinEdgeInsets:(UIEdgeInsets)edgeInsets andCenteredGrid:(BOOL)centered {
    do {
        _itemSize      = itemSize;
        _itemSpacing   = spacing;
        _minEdgeInsets = edgeInsets;
        _centeredGrid  = centered;
    } while (NO);
}

- (void)setEdgeAndContentSizeFromAbsoluteContentSize:(CGSize)actualContentSize {
    do {
        if (self.centeredGrid) {
            NSInteger widthSpace = floor((self.gridBounds.size.width - actualContentSize.width) / 2.0);
            NSInteger heightSpace = floor((self.gridBounds.size.height - actualContentSize.height) / 2.0);
            
            NSInteger left = MAX(widthSpace, self.minEdgeInsets.left);
            NSInteger right = MAX(widthSpace, self.minEdgeInsets.right);
            NSInteger top = MAX(heightSpace, self.minEdgeInsets.top);
            NSInteger bottom = MAX(heightSpace, self.minEdgeInsets.bottom);
            
            _edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
        } else {
            _edgeInsets = self.minEdgeInsets;
        }
        
        _contentSize = CGSizeMake(actualContentSize.width + self.edgeInsets.left + self.edgeInsets.right, actualContentSize.height + self.edgeInsets.top + self.edgeInsets.bottom);
    } while (NO);
}

@end


#pragma mark - implementation DCGridViewLayoutVerticalStrategy
@implementation DCGridViewLayoutVerticalStrategy

@synthesize numberOfItemsPerRow = _numberOfItemsPerRow;

+ (BOOL)requiresEnablingPaging {
    return NO;
}

- (id)init {
    if ((self = [super init])) {
        _type = DCGridViewLayoutVertical;
    }
    
    return self;
}

- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds {
    do {
        _itemCount  = count;
        _gridBounds = bounds;
        
        CGRect actualBounds = CGRectMake(0, 0, bounds.size.width  - self.minEdgeInsets.right - self.minEdgeInsets.left, bounds.size.height - self.minEdgeInsets.top   - self.minEdgeInsets.bottom);
        
        _numberOfItemsPerRow = 1;
        
        while ((self.numberOfItemsPerRow + 1) * (self.itemSize.width + self.itemSpacing) - self.itemSpacing <= actualBounds.size.width) {
            ++_numberOfItemsPerRow;
        }
        
        NSInteger numberOfRows = ceil(self.itemCount / (1.0 * self.numberOfItemsPerRow));
        
        CGSize actualContentSize = CGSizeMake(ceil(MIN(self.itemCount, self.numberOfItemsPerRow) * (self.itemSize.width + self.itemSpacing)) - self.itemSpacing, ceil(numberOfRows * (self.itemSize.height + self.itemSpacing)) - self.itemSpacing);
        
        [self setEdgeAndContentSizeFromAbsoluteContentSize:actualContentSize];
    } while (NO);
}

- (CGPoint)originForItemAtPosition:(NSInteger)position {
    CGPoint origin = CGPointZero;
    do {
        if (self.numberOfItemsPerRow > 0 && position >= 0)
        {
            NSUInteger col = position % self.numberOfItemsPerRow;
            NSUInteger row = position / self.numberOfItemsPerRow;
            
            origin = CGPointMake(col * (self.itemSize.width + self.itemSpacing) + self.edgeInsets.left, row * (self.itemSize.height + self.itemSpacing) + self.edgeInsets.top);
        }
    } while (NO);
    return origin;
}

- (NSInteger)itemPositionFromLocation:(CGPoint)location {
    NSInteger position = DCGV_INVALID_POSITION;
    do {
        CGPoint relativeLocation = CGPointMake(location.x - self.edgeInsets.left, location.y - self.edgeInsets.top);
        
        int col = (int) (relativeLocation.x / (self.itemSize.width + self.itemSpacing));
        int row = (int) (relativeLocation.y / (self.itemSize.height + self.itemSpacing));
        
        position = col + row * self.numberOfItemsPerRow;
        
        if (position >= [self itemCount] || position < 0) {
            position = DCGV_INVALID_POSITION;
        } else {
            CGPoint itemOrigin = [self originForItemAtPosition:position];
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, self.itemSize.width, self.itemSize.height);
            
            if (!CGRectContainsPoint(itemFrame, location)) {
                position = DCGV_INVALID_POSITION;
            }
        }
    } while (NO);
    return position;
}

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset {
    NSRange result;
    do {
        CGPoint contentOffset = CGPointMake(MAX(0, offset.x), MAX(0, offset.y));
        
        CGFloat itemHeight = self.itemSize.height + self.itemSpacing;
        
        CGFloat firstRow = MAX(0, (int)(contentOffset.y / itemHeight) - 1);
        
        CGFloat lastRow = ceil((contentOffset.y + self.gridBounds.size.height) / itemHeight);
        
        NSInteger firstPosition = firstRow * self.numberOfItemsPerRow;
        NSInteger lastPosition  = ((lastRow + 1) * self.numberOfItemsPerRow);
        
        result = NSMakeRange(firstPosition, (lastPosition - firstPosition));
    } while (NO);
    return result;
}

@end


#pragma mark - implementation DCGridViewLayoutHorizontalStrategy
@implementation DCGridViewLayoutHorizontalStrategy

@synthesize numberOfItemsPerColumn = _numberOfItemsPerColumn;

+ (BOOL)requiresEnablingPaging {
    return NO;
}

- (id)init {
    if ((self = [super init])) {
        _type = DCGridViewLayoutHorizontal;
    }
    
    return self;
}

- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds {
    do {
        _itemCount  = count;
        _gridBounds = bounds;
        
        CGRect actualBounds = CGRectMake(0, 0, bounds.size.width  - self.minEdgeInsets.right - self.minEdgeInsets.left, bounds.size.height - self.minEdgeInsets.top   - self.minEdgeInsets.bottom);
        
        _numberOfItemsPerColumn = 1;
        
        while ((_numberOfItemsPerColumn + 1) * (self.itemSize.height + self.itemSpacing) - self.itemSpacing <= actualBounds.size.height) {
            ++_numberOfItemsPerColumn;
        }
        
        NSInteger numberOfColumns = ceil(self.itemCount / (1.0 * self.numberOfItemsPerColumn));
        
        CGSize actualContentSize = CGSizeMake(ceil(numberOfColumns * (self.itemSize.width + self.itemSpacing)) - self.itemSpacing, ceil(MIN(self.itemCount, self.numberOfItemsPerColumn) * (self.itemSize.height + self.itemSpacing)) - self.itemSpacing);
        
        [self setEdgeAndContentSizeFromAbsoluteContentSize:actualContentSize];
    } while (NO);
}

- (CGPoint)originForItemAtPosition:(NSInteger)position {
    CGPoint origin = CGPointZero;
    do {
        if (self.numberOfItemsPerColumn > 0 && position >= 0) {
            NSUInteger col = position / self.numberOfItemsPerColumn;
            NSUInteger row = position % self.numberOfItemsPerColumn;
            
            origin = CGPointMake(col * (self.itemSize.width + self.itemSpacing) + self.edgeInsets.left, row * (self.itemSize.height + self.itemSpacing) + self.edgeInsets.top);
        }
    } while (NO);
    return origin;
}

- (NSInteger)itemPositionFromLocation:(CGPoint)location {
    NSInteger position = DCGV_INVALID_POSITION;
    do {
        CGPoint relativeLocation = CGPointMake(location.x - self.edgeInsets.left, location.y - self.edgeInsets.top);
        
        int col = (int) (relativeLocation.x / (self.itemSize.width + self.itemSpacing));
        int row = (int) (relativeLocation.y / (self.itemSize.height + self.itemSpacing));
        
        int position = row + col * self.numberOfItemsPerColumn;
        
        if (position >= [self itemCount] || position < 0) {
            position = DCGV_INVALID_POSITION;
        } else {
            CGPoint itemOrigin = [self originForItemAtPosition:position];
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, self.itemSize.width, self.itemSize.height);
            
            if (!CGRectContainsPoint(itemFrame, location)) {
                position = DCGV_INVALID_POSITION;
            }
        }
    } while (NO);
    return position;
}

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset {
    NSRange result;
    do {
        CGPoint contentOffset = CGPointMake(MAX(0, offset.x), MAX(0, offset.y));
        
        CGFloat itemWidth = self.itemSize.width + self.itemSpacing;
        
        CGFloat firstCol = MAX(0, (int)(contentOffset.x / itemWidth) - 1);
        
        CGFloat lastCol = ceil((contentOffset.x + self.gridBounds.size.width) / itemWidth);
        
        NSInteger firstPosition = firstCol * self.numberOfItemsPerColumn;
        NSInteger lastPosition  = ((lastCol + 1) * self.numberOfItemsPerColumn);
        
        result = NSMakeRange(firstPosition, (lastPosition - firstPosition));
    } while (NO);
    return result;
}

@end


#pragma mark - implementation DCGridViewLayoutHorizontalPagedStrategy
@implementation DCGridViewLayoutHorizontalPagedStrategy

@synthesize numberOfItemsPerPage = _numberOfItemsPerPage;
@synthesize numberOfItemsPerRow = _numberOfItemsPerRow;
@synthesize numberOfPages = _numberOfPages;

+ (BOOL)requiresEnablingPaging {
    return YES;
}

- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds {
    do {
        [super rebaseWithItemCount:count insideOfBounds:bounds];
        
        _numberOfItemsPerRow = 1;
        
        NSInteger gridContentMaxWidth = self.gridBounds.size.width - self.minEdgeInsets.right - self.minEdgeInsets.left;
        
        while ((self.numberOfItemsPerRow + 1) * (self.itemSize.width + self.itemSpacing) - self.itemSpacing <= gridContentMaxWidth) {
            ++_numberOfItemsPerRow;
        }
        
        _numberOfItemsPerPage = _numberOfItemsPerRow * _numberOfItemsPerColumn;
        _numberOfPages = ceil(self.itemCount * 1.0 / self.numberOfItemsPerPage);
        
        CGSize onePageSize = CGSizeMake(self.numberOfItemsPerRow * (self.itemSize.width + self.itemSpacing) - self.itemSpacing, self.numberOfItemsPerColumn * (self.itemSize.height + self.itemSpacing) - self.itemSpacing);
        
        if (self.centeredGrid) {
            NSInteger widthSpace = floor((self.gridBounds.size.width - onePageSize.width) / 2.0);
            NSInteger heightSpace = floor((self.gridBounds.size.height - onePageSize.height) / 2.0);
            
            NSInteger left = MAX(widthSpace, self.minEdgeInsets.left);
            NSInteger right = MAX(widthSpace, self.minEdgeInsets.right);
            NSInteger top = MAX(heightSpace, self.minEdgeInsets.top);
            NSInteger bottom = MAX(heightSpace, self.minEdgeInsets.bottom);
            
            _edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
        } else {
            _edgeInsets = self.minEdgeInsets;
        }
        
        _contentSize = CGSizeMake(bounds.size.width * self.numberOfPages, bounds.size.height);
    } while (NO);
}

- (NSInteger)pageForItemAtIndex:(NSInteger)index {
    NSInteger result = 0;
    do {
        result = MAX(0, floor(index * 1.0 / self.numberOfItemsPerPage * 1.0));
    } while (NO);
    return result;
}

- (CGPoint)originForItemAtColumn:(NSInteger)column row:(NSInteger)row page:(NSInteger)page {
    CGPoint result = CGPointZero;
    do {
        CGPoint offset = CGPointMake(page * self.gridBounds.size.width, 0);
        
        CGFloat x = column * (self.itemSize.width + self.itemSpacing) + self.edgeInsets.left;
        CGFloat y = row * (self.itemSize.height + self.itemSpacing) + self.edgeInsets.top;
        
        result = CGPointMake(x + offset.x, y + offset.y);
    } while (NO);
    return result;
}

- (NSInteger)positionForItemAtColumn:(NSInteger)column row:(NSInteger)row page:(NSInteger)page {
    NSInteger result = 0;
    do {
        result = column + row * self.numberOfItemsPerRow + (page * self.numberOfItemsPerPage);
    } while (NO);
    return result;
}

- (NSInteger)columnForItemAtPosition:(NSInteger)position {
    NSInteger result = 0;
    do {
        position %= self.numberOfItemsPerPage;
        result = position % self.numberOfItemsPerRow;
    } while (NO);
    return result;
    
}

- (NSInteger)rowForItemAtPosition:(NSInteger)position {
    NSInteger result = 0;
    do {
        position %= self.numberOfItemsPerPage;
        result = floor(position / self.numberOfItemsPerRow);
    } while (NO);
    return result;
}

- (CGPoint)originForItemAtPosition:(NSInteger)position {
    CGPoint origin = CGPointZero;
    do {
        NSUInteger page = [self pageForItemAtIndex:position];
        
        position %= self.numberOfItemsPerPage;
        
        NSUInteger row = [self rowForItemAtPosition:position];
        NSUInteger column = [self columnForItemAtPosition:position];
        
        origin = [self originForItemAtColumn:column row:row page:page];
    } while (NO);
    return origin;
}

- (NSInteger)itemPositionFromLocation:(CGPoint)location {
    NSInteger position = DCGV_INVALID_POSITION;
    do {
        CGFloat page = 0;
        while ((page + 1) * self.gridBounds.size.width < location.x) {
            ++page;
        }
        
        CGPoint originForFirstItemInPage = [self originForItemAtColumn:0 row:0 page:page];
        
        CGPoint relativeLocation = CGPointMake(location.x - originForFirstItemInPage.x, location.y - originForFirstItemInPage.y);
        
        int col = (int) (relativeLocation.x / (self.itemSize.width + self.itemSpacing));
        int row = (int) (relativeLocation.y / (self.itemSize.height + self.itemSpacing));
        
        position = [self positionForItemAtColumn:col row:row page:page];
        
        if (position >= [self itemCount] || position < 0) {
            position = DCGV_INVALID_POSITION;
        } else {
            CGPoint itemOrigin = [self originForItemAtPosition:position];
            CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, self.itemSize.width, self.itemSize.height);
            
            if (!CGRectContainsPoint(itemFrame, location)) {
                position = DCGV_INVALID_POSITION;
            }
        }

    } while (NO);
    return position;
}

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset {
    NSRange result;
    do {
        CGPoint contentOffset = CGPointMake(MAX(0, offset.x), MAX(0, offset.y));
        
        NSInteger page = floor(contentOffset.x / self.gridBounds.size.width);
        
        NSInteger firstPosition = MAX(0, (page - 1) * self.numberOfItemsPerPage);
        NSInteger lastPosition  = MIN(firstPosition + 3 * self.numberOfItemsPerPage, self.itemCount);
        
        result = NSMakeRange(firstPosition, (lastPosition - firstPosition));
    } while (NO);
    return result;
}

@end


#pragma mark - implementation DCGridViewLayoutHorizontalPagedL2RStrategy
@implementation DCGridViewLayoutHorizontalPagedL2RStrategy

- (id)init {
    if ((self = [super init])) {
        _type = DCGridViewLayoutHorizontalPagedLeftToRight;
    }
    
    return self;
}

// Nothing to change, LTR is already the behavior of the base class

@end


#pragma mark - implementation DCGridViewLayoutHorizontalPagedT2BStrategy
@implementation DCGridViewLayoutHorizontalPagedT2BStrategy

- (id)init {
    if ((self = [super init])) {
        _type = DCGridViewLayoutHorizontalPagedTopToBottom;
    }
    
    return self;
}

- (NSInteger)positionForItemAtColumn:(NSInteger)column row:(NSInteger)row page:(NSInteger)page {
    NSInteger result = 0;
    do {
        result = row + column * self.numberOfItemsPerColumn + (page * self.numberOfItemsPerPage);
    } while (NO);
    return result;
}

- (NSInteger)columnForItemAtPosition:(NSInteger)position {
    NSInteger result = 0;
    do {
        position %= self.numberOfItemsPerPage;
        result = floor(position / self.numberOfItemsPerColumn);
    } while (NO);
    return result;
}

- (NSInteger)rowForItemAtPosition:(NSInteger)position {
    NSInteger result = 0;
    do {
        position %= self.numberOfItemsPerPage;
        result = position % self.numberOfItemsPerColumn;
    } while (NO);
    return result;
}

@end

