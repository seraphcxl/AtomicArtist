//
//  DCGroupView.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupView.h"
#import "DCAssetLibHelper.h"

@interface DCGroupView () {
    UITapGestureRecognizer *tapGestureRecognizer;
}

- (NSInteger)calcPosterImageSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UIPanGestureRecognizer *)gr;

@end

@implementation DCGroupView

@synthesize delegate = _delegate;
@synthesize groupPersistentID = _groupPersistentID;
@synthesize posterImageSize = _posterImageSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize posterImage = _posterImage;

- (void)refreshAssets:(BOOL)force {
    DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
    if (force || [assetLibHelper assetCountForGroupWithPersistentID:self.groupPersistentID] == 0) {
        [assetLibHelper cleaeCacheForGoupPersistentID:self.groupPersistentID];
        [assetLibHelper enumerateAssetsForGoupPersistentID:self.groupPersistentID];
    }
}

- (void)tap:(UIPanGestureRecognizer *)gr {
    NSLog(@"DCGroupView tap:");
    if (self.delegate && self.groupPersistentID) {
        [self.delegate selectGroup:self.groupPersistentID];
    }
}

- (void)dealloc {
    if (tapGestureRecognizer) {
        [self removeGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        tapGestureRecognizer = nil;
    }
    
    self.posterImage = nil;
    self.groupPersistentID = nil;
    
    [super dealloc];
}

- (NSInteger)calcPosterImageSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return GROUPVIEW_SIZE_POSTERIMAGE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return GROUPVIEW_SIZE_POSTERIMAGE_IPAD;
    } else {
        [NSException raise:@"DCGroupView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (NSInteger)calcTitleFontSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return GROUPVIEW_TITLELABEL_FONT_SIZE_IPHONE;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return GROUPVIEW_TITLELABEL_FONT_SIZE_IPAD;
    } else {
        [NSException raise:@"DCGroupView error" format:@"Reason: Current device type unknown"];
        return 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (self.posterImageSize == 0 || !self.groupPersistentID) {
            break;
        }
        DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
        ALAssetsGroup *group = [assetLibHelper getALGroupForGoupPersistentID:self.groupPersistentID];
        if (!group) {
            break;
        }
        CGRect bounds = [self bounds];
        CGRect imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2), bounds.origin.y, self.posterImageSize, self.posterImageSize);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
        self.posterImage = [[[UIImage alloc] initWithCGImage:[group posterImage]] autorelease];
        [imageView setImage:self.posterImage];
        
        CGRect titleLabelFrame = CGRectMake(bounds.origin.x, bounds.origin.y + self.posterImageSize + GROUPVIEW_TITLELABEL_SPACE, bounds.size.width, GROUPVIEW_TITLELABEL_HEIGHT);
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:titleLabelFrame] autorelease];
        NSString *groupPropertyName = [group valueForProperty:ALAssetsGroupPropertyName];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [titleLabel setText:[[[NSString alloc] initWithFormat:@"%@", groupPropertyName] autorelease]];
        
        CGRect numberLabelFrame = CGRectMake(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y, bounds.size.width / 2.0, GROUPVIEW_TITLELABEL_HEIGHT);
        UILabel *numbereLabel = [[[UILabel alloc] initWithFrame:numberLabelFrame] autorelease];
        NSInteger numberOfAssets = [group numberOfAssets];
        [numbereLabel setBackgroundColor:[UIColor clearColor]];
		[numbereLabel setTextColor:[UIColor whiteColor]];
		numbereLabel.textAlignment = UITextAlignmentRight;
		numbereLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [numbereLabel setText:[[[NSString alloc] initWithFormat:@"%d", numberOfAssets] autorelease]];
        
        [self addSubview:imageView];
        [self addSubview:titleLabel];
        [self addSubview:numbereLabel];
    } while (NO);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _posterImageSize = [self calcPosterImageSize];
        _titleFontSize = [self calcTitleFontSize];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
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
