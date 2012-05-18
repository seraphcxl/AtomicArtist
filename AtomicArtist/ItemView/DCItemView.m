//
//  DCItemView.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCItemView.h"

@interface DCItemView () {
    UITapGestureRecognizer *_singleTapGestureRecognizer;
}

- (NSInteger)calcThumbnailSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UITapGestureRecognizer *)gr;

@end


@implementation DCItemView

@synthesize delegate = _delegate;
@synthesize itemUID = _itemUID;
@synthesize thumbnailSize = _thumbnailSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize thumbnail = _thumbnail;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize dataLibraryHelper = _dataLibraryHelper;

- (void)tap:(UITapGestureRecognizer *)gr {
    if (gr == _singleTapGestureRecognizer && gr.numberOfTapsRequired == 1) {
        NSLog(@"DCItemView tap:single");
        if (self.delegate && self.itemUID) {
            [self.delegate selectItem:self.itemUID];
        }
    }
}

- (void)dealloc {
    if (_singleTapGestureRecognizer) {
        [self removeGestureRecognizer:_singleTapGestureRecognizer];
        [_singleTapGestureRecognizer release];
        _singleTapGestureRecognizer = nil;
    }
    
    self.dataLibraryHelper = nil;
    self.thumbnail = nil;
    self.itemUID = nil;
    
    if (_dataGroupUID) {
        [_dataGroupUID release];
        _dataGroupUID = nil;
    }
    
    [super dealloc];
}

- (NSInteger)calcThumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_SIZE_FRAME_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_SIZE_FRAME_IPAD;
    } else {
        [NSException raise:@"DCItemView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSInteger)calcTitleFontSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_TITLELABEL_FONT_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_TITLELABEL_FONT_SIZE_IPAD;
    } else {
        [NSException raise:@"DCItemView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (self.thumbnailSize == 0 || !self.itemUID) {
            break;
        }
        if (self.dataLibraryHelper) {
            id <DCDataItem> item = [self.dataLibraryHelper itemWithUID:self.itemUID inGroup:self.dataGroupUID];
            if (!item) {
                break;
            }
            CGRect bounds = [self bounds];
            
            self.thumbnail = (UIImage *)[item valueForProperty:kDATAITEMPROPERTY_THUMBNAIL withOptions:nil];
            CGSize thimbnailSize = [self.thumbnail size];
            CGRect imageViewFrame = CGRectMake(bounds.origin.x + ((self.thumbnailSize - thimbnailSize.width) / 2.0), bounds.origin.y + ((self.thumbnailSize - thimbnailSize.height) / 2.0), thimbnailSize.width, thimbnailSize.height);
            UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
            [imageView setImage:self.thumbnail];
            
            [self addSubview:imageView];
        } else {
            [NSException raise:@"DCItemView error" format:@"Reason: self.dataLibraryHelper == nil"];
        }
    } while (NO);
}

- (id)InitWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper dataGroupUID:(NSString *)dataGroupUID andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _thumbnailSize = [self calcThumbnailSize];
        _titleFontSize = [self calcTitleFontSize];
        _dataGroupUID = dataGroupUID;
        [_dataGroupUID retain];
        self.dataLibraryHelper = dataLibraryHelper;
        
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_singleTapGestureRecognizer];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
