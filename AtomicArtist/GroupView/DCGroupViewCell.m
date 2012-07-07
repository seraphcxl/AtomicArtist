//
//  DCGroupViewCell.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupViewCell.h"

@interface DCGroupViewCell () {
    NSMutableArray *_groupViews;
}

@end

@implementation DCGroupViewCell

@synthesize delegate = _delegate;
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize tableViewMargin = _tableViewMargin;
@synthesize itemCount = _itemCount;
@synthesize dataGroupViews = _dataGroupViews;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        CGRect viewFrame = CGRectMake(self.tableViewMargin, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (UIView *view in self.dataGroupViews) {
            if (view && [view isMemberOfClass:[DCGroupView class]]) {
                DCGroupView *groupView = (DCGroupView *)view;
                [groupView setFrame:viewFrame];
                
                [self addSubview:groupView];
                
                if (_groupViews) {
                    [_groupViews addObject:view];
                } else {
                    [NSException raise:@"DCGroupViewCell error" format:@"Reason: _groupViews == nil"];
                }
                
                viewFrame.origin.x += (self.frameSize + self.cellSpace);
            }
        }
    } while (NO);
}

- (id)initWithDataGroupViews:(NSArray *)dataGroupViews cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCGroupViewCell"];
    if (self) {
        if (_groupViews) {
            for (DCGroupView *view in _groupViews) {
                [view removeFromSuperview];
            }
            [_groupViews removeAllObjects];
        } else {
            _groupViews = [[NSMutableArray alloc] init];
        }
        
        self.dataGroupViews = dataGroupViews;
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _tableViewMargin = tableViewMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    if (_groupViews) {
        [_groupViews removeAllObjects];
        [_groupViews release];
        _groupViews = nil;
    }
    
    self.dataGroupViews = nil;
    self.delegate = nil;
    
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
