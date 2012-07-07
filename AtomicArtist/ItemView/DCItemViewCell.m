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
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize tableViewMargin = _tableViewMargin;
@synthesize itemCount = _itemCount;
@synthesize dataItemViews = _dataItemViews;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        CGRect viewFrame = CGRectMake(self.tableViewMargin, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (UIView *view in self.dataItemViews) {
            if (view && [view isMemberOfClass:[DCItemView class]]) {
                DCItemView *itemView = (DCItemView *)view;
                [itemView setFrame:viewFrame];
                
                [self addSubview:itemView];
                
                if (_itemViews) {
                    [_itemViews addObject:view];
                } else {
                    [NSException raise:@"DCItemViewCell error" format:@"Reason: _itemViews == nil"];
                }
                
                viewFrame.origin.x += (self.frameSize + self.cellSpace);
            }
        }
    } while (NO);
}

- (id)initWithDataItemViews:(NSArray *)dataItemViews cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCItemViewCell"];
    if (self) {
        if (_itemViews) {
            for (DCItemView *view in _itemViews) {
                [view removeFromSuperview];
            }
            [_itemViews removeAllObjects];
        } else {
            _itemViews = [[NSMutableArray alloc] init];
        }
        
        self.dataItemViews = dataItemViews;
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _tableViewMargin = tableViewMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    self.dataItemViews = nil;
    
    if (_itemViews) {
        [_itemViews removeAllObjects];
        [_itemViews release];
        _itemViews = nil;
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
