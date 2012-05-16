//
//  AAGroupViewCell.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "AAGroupViewCell.h"

@implementation AAGroupViewCell

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
            AAGroupView *view = nil;
            if (self.delegate) {
                view = [self.delegate getGroupViewWithGroupPersistentID:groupPersistentID];
            }
            
            if (!view) {
                view = [[[AAGroupView alloc] initWithFrame:viewFrame] autorelease];
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
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AAGroupViewCell"];
    if (self) {
        for (UIView *view in [self subviews]) {
            if ([view isMemberOfClass:[AAGroupView class]]) {
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
