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
@synthesize groupPersistentIDs = _groupPersistentIDs;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        CGRect viewFrame = CGRectMake(self.cellSpace, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (NSString *groupPersistentID in self.groupPersistentIDs) {
            DCGroupView *view = nil;
            if (self.delegate) {
                view = [self.delegate getGroupViewWithGroupPersistentID:groupPersistentID];
            }
            
            if (!view) {
                view = [[[DCGroupView alloc] initWithFrame:viewFrame] autorelease];
                view.delegate = self.delegateForGroupView;
                view.groupPersistentID = groupPersistentID;
                if (self.delegate) {
                    [self.delegate addGroupView:view];
                }
            }
            
            [self addSubview:view];
            
            viewFrame.origin.x += (self.frameSize + self.cellSpace);
        }
    } while (NO);
}

- (id)initWithGroupPersistentIDs:(NSArray *)groupPersistentIDs cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCGroupViewCell"];
    if (self) {
        for (UIView *view in [self subviews]) {
            if ([view isMemberOfClass:[DCGroupView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.groupPersistentIDs = groupPersistentIDs;
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    self.groupPersistentIDs = nil;
    
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
