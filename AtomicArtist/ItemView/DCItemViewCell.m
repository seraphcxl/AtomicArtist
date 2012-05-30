//
//  DCItemViewCell.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCItemViewCell.h"

@interface DCItemViewCell () {
    NSMutableArray *_itemViews;
}

@end

@implementation DCItemViewCell

@synthesize delegate = _delegate;
@synthesize delegateForItemView = _delegateForItemView;
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize tableViewMargin = _tableViewMargin;
@synthesize itemCount = _itemCount;
@synthesize itemUIDs = _itemUIDs;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (!self.dataGroupUID) {
            [NSException raise:@"AAItemViewCell error" format:@"self.dataGroupUID == nil"];
            break;
        }
        
        if (!self.dataLibraryHelper) {
            [NSException raise:@"AAItemViewCell error" format:@"self.dataLibraryHelper == nil"];
            break;
        }
        
        CGRect viewFrame = CGRectMake(self.tableViewMargin, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (NSString *itemUID in self.itemUIDs) {
            DCItemView *view = nil;
            if (self.delegate) {
                view = [self.delegate getItemViewWithItemUID:itemUID];
            }
            
            if (!view) {
                view = [[[DCItemView alloc] InitWithDataLibraryHelper:self.dataLibraryHelper itemUID:itemUID dataGroupUID:self.dataGroupUID andFrame:viewFrame] autorelease];
                view.delegate = self.delegateForItemView;
                
                if (self.delegate) {
                    [self.delegate addItemView:view];
                }
            } else {
                if (view.loadThumbnailOperation) {
                    [view.loadThumbnailOperation setQueuePriority:NSOperationQueuePriorityNormal];
                }
            }
            
            [self addSubview:view];
            
            if (_itemViews) {
                [_itemViews addObject:view];
            } else {
                [NSException raise:@"DCItemViewCell error" format:@"Reason: _itemViews == nil"];
            }
            
            viewFrame.origin.x += (self.frameSize + self.cellSpace);
        }
    } while (NO);
}

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper itemUIDs:(NSArray *)itemUIDs dataGroupUID:(NSString *)dataGroupUID cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCItemViewCell"];
    if (self) {
        if (_itemViews) {
            for (DCItemView *view in _itemViews) {
                [view.loadThumbnailOperation setQueuePriority:NSOperationQueuePriorityLow];
                [view removeFromSuperview];
            }
            [_itemViews removeAllObjects];
        } else {
            _itemViews = [[NSMutableArray alloc] init];
        }
        
        self.dataLibraryHelper = dataLibraryHelper;
        self.itemUIDs = itemUIDs;
        _dataGroupUID = dataGroupUID;
        [_dataGroupUID retain];
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _tableViewMargin = tableViewMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    self.dataLibraryHelper = nil;
    self.itemUIDs = nil;
    
    if (_itemViews) {
        [_itemViews removeAllObjects];
        [_itemViews release];
        _itemViews = nil;
    }
    
    if (_dataGroupUID) {
        [_dataGroupUID release];
        _dataGroupUID = nil;
    }
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
