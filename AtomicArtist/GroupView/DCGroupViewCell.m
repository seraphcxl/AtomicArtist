//
//  DCGroupViewCell.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupViewCell.h"

@implementation DCGroupViewCell

@synthesize delegate = _delegate;
@synthesize delegateForGroupView = _delegateForGroupView;
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize itemCount = _itemCount;
@synthesize dataGroupUIDs = _dataGroupUIDs;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        CGRect viewFrame = CGRectMake(self.cellSpace, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (NSString *dataGroupUID in self.dataGroupUIDs) {
            DCGroupView *view = nil;
            if (self.delegate) {
                view = [self.delegate getGroupViewWithDataGroupUID:dataGroupUID];
            }
            
            if (!view) {
                view = [[[DCGroupView alloc] initWithFrame:viewFrame] autorelease];
                view.delegate = self.delegateForGroupView;
                view.groupPersistentID = dataGroupUID;
                if (self.delegate) {
                    [self.delegate addGroupView:view];
                }
            }
            
            [self addSubview:view];
            
            viewFrame.origin.x += (self.frameSize + self.cellSpace);
        }
    } while (NO);
}

- (id)initWithDataLibHelper:(id<DCDataLibraryHelper>)dataLibraryHelper dataGroupUIDs:(NSArray *)dataGroupUIDs cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCGroupViewCell"];
    if (self) {
        for (UIView *view in [self subviews]) {
            if ([view isMemberOfClass:[DCGroupView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.dataGroupUIDs = dataGroupUIDs;
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    self.dataGroupUIDs = nil;
    
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
