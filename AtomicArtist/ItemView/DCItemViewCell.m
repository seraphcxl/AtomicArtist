//
//  DCItemViewCell.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCItemViewCell.h"

@implementation DCItemViewCell

@synthesize delegate = _delegate;
@synthesize delegateForItemView = _delegateForItemView;
@synthesize cellSpace = _cellSpace;
@synthesize cellTopBottomMargin = _cellTopBottomMargin;
@synthesize frameSize = _frameSize;
@synthesize itemCount = _itemCount;
@synthesize assetURLs = _assetURLs;
@synthesize groupPersistentID = _groupPersistentID;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (!self.groupPersistentID) {
            [NSException raise:@"AAItemViewCell error" format:@"self.groupPersistentID == nil"];
            break;
        }
        
        CGRect viewFrame = CGRectMake(self.cellSpace, self.cellTopBottomMargin, self.frameSize, self.frameSize);
        
        for (NSURL *assetURL in self.assetURLs) {
            DCItemView *view = nil;
            if (self.delegate) {
                view = [self.delegate getItemViewWithAssetURL:assetURL];
            }
            
            if (!view) {
                view = [[[DCItemView alloc] InitWithGroupPersistentID:self.groupPersistentID andFrame:viewFrame] autorelease];
                view.delegate = self.delegateForItemView;
                view.assetURL = assetURL;
                
                if (self.delegate) {
                    [self.delegate addItemView:view];
                }
            }
            
            [self addSubview:view];
            
            viewFrame.origin.x += (self.frameSize + self.cellSpace);
        }
    } while (NO);
}

- (id)initWithAssetURLs:(NSArray *)assetURLs groupPersistentID:(NSString *)groupPersistentID cellSpace:(NSUInteger)cellSpace cellTopBottomMargin:(NSUInteger)cellTopBottomMargin frameSize:(NSUInteger)frameSize andItemCount:(NSUInteger)itemCount {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCItemViewCell"];
    if (self) {
        for (UIView *view in [self subviews]) {
            if ([view isMemberOfClass:[DCItemView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.assetURLs = assetURLs;
        _groupPersistentID = groupPersistentID;
        [_groupPersistentID retain];
        _cellSpace = cellSpace;
        _cellTopBottomMargin = cellTopBottomMargin;
        _frameSize = frameSize;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc {
    self.assetURLs = nil;
    
    if (_groupPersistentID) {
        [_groupPersistentID release];
        _groupPersistentID = nil;
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
