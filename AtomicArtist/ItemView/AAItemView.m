//
//  AAItemView.m
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import "AAItemView.h"
#import "AAAssetLibHelper.h"

@interface AAItemView () {
    UITapGestureRecognizer *_singleTapGestureRecognizer;
}

- (NSInteger)calcThumbnailSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UITapGestureRecognizer *)gr;

@end

@implementation AAItemView

@synthesize delegate = _delegate;
@synthesize assetURL = _assetURL;
@synthesize thumbnailSize = _thumbnailSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize thumbnail = _thumbnail;
@synthesize groupPersistentID = _groupPersistentID;

- (void)tap:(UITapGestureRecognizer *)gr {
    if (gr == _singleTapGestureRecognizer && gr.numberOfTapsRequired == 1) {
        NSLog(@"AAItemView tap:single");
        if (self.delegate && self.assetURL) {
            [self.delegate selectItem:self.assetURL];
        }
    }
}

- (void)dealloc {
    if (_singleTapGestureRecognizer) {
        [self removeGestureRecognizer:_singleTapGestureRecognizer];
        [_singleTapGestureRecognizer release];
        _singleTapGestureRecognizer = nil;
    }
    
    self.thumbnail = nil;
    self.assetURL = nil;
    
    if (_groupPersistentID) {
        [_groupPersistentID release];
        _groupPersistentID = nil;
    }
    
    [super dealloc];
}

- (NSInteger)calcThumbnailSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_SIZE_FRAME_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_SIZE_FRAME_IPAD;
    } else {
        [NSException raise:@"AAItemView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSInteger)calcTitleFontSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ITEMVIEW_TITLELABEL_FONT_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return ITEMVIEW_TITLELABEL_FONT_SIZE_IPAD;
    } else {
        [NSException raise:@"AAItemView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (self.thumbnailSize == 0 || !self.assetURL) {
            break;
        }
        AAAssetLibHelper *assetLibHelper = [AAAssetLibHelper defaultAssetLibHelper];
        ALAsset *asset = [assetLibHelper getALAssetForGoupPersistentID:self.groupPersistentID forAssetURL:self.assetURL];
        if (!asset) {
            break;
        }
        CGRect bounds = [self bounds];
        CGRect imageViewFrame = CGRectMake(bounds.origin.x, bounds.origin.y, self.thumbnailSize, self.thumbnailSize);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
        self.thumbnail = [[[UIImage alloc] initWithCGImage:[asset thumbnail]] autorelease];
//        CGSize thumbnailSize = self.thumbnail.size;
        [imageView setImage:self.thumbnail];
        
        [self addSubview:imageView];
    } while (NO);
}

- (id)InitWithGroupPersistentID:(NSString *)groupPersistentID andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _thumbnailSize = [self calcThumbnailSize];
        _titleFontSize = [self calcTitleFontSize];
        _groupPersistentID = groupPersistentID;
        [_groupPersistentID retain];
        
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
