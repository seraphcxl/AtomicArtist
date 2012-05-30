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
@synthesize delegateForGroupView = _delegateForGroupView;
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize tableViewMargin = _tableViewMargin;
@synthesize itemCount = _itemCount;
@synthesize dataGroupUIDs = _dataGroupUIDs;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize enumDataItemParam = _enumDataItemParam;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        CGRect viewFrame = CGRectMake(self.tableViewMargin, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (NSString *dataGroupUID in self.dataGroupUIDs) {
            DCGroupView *view = nil;
            if (self.delegate) {
                view = [self.delegate getGroupViewWithDataGroupUID:dataGroupUID];
            }
            
            if (!view) {
                view = [[[DCGroupView alloc] initWithFrame:viewFrame] autorelease];
                view.delegate = self.delegateForGroupView;
                view.dataGroupUID = dataGroupUID;
                view.dataLibraryHelper = self.dataLibraryHelper;
                view.enumDataItemParam = self.enumDataItemParam;
                if (self.delegate) {
                    [self.delegate addGroupView:view];
                }
            } else {
                if (view.loadPosterImageOperation) {
                    [view.loadPosterImageOperation setQueuePriority:NSOperationQueuePriorityNormal];
                }
            }
            
            [self addSubview:view];
            
            if (_groupViews) {
                [_groupViews addObject:view];
            } else {
                [NSException raise:@"DCGroupViewCell error" format:@"Reason: _groupViews == nil"];
            }
            
            viewFrame.origin.x += (self.frameSize + self.cellSpace);
        }
    } while (NO);
}

- (id)initWithDataLibHelper:(id <DCDataLibraryHelper>)dataLibraryHelper dataGroupUIDs:(NSArray *)dataGroupUIDs enumDataItemParam:(id)enumDataItemParam cellSpace:(double)cellSpace cellTopBottomMargin:(double)cellTopBottomMargin tableViewMargin:(NSUInteger)tableViewMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCGroupViewCell"];
    if (self) {
        if (_groupViews) {
            for (DCGroupView *view in _groupViews) {
                [view.loadPosterImageOperation setQueuePriority:NSOperationQueuePriorityLow];
                [view removeFromSuperview];
            }
            [_groupViews removeAllObjects];
        } else {
            _groupViews = [[NSMutableArray alloc] init];
        }
        
        self.dataLibraryHelper = dataLibraryHelper;
        self.enumDataItemParam = enumDataItemParam;
        self.dataGroupUIDs = dataGroupUIDs;
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
    
    self.dataGroupUIDs = nil;
    self.enumDataItemParam = nil;
    self.dataLibraryHelper = nil;
    self.delegate = nil;
    self.delegateForGroupView = nil;
    
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
