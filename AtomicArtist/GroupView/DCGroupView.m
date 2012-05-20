//
//  DCGroupView.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupView.h"

@interface DCGroupView () {
    UITapGestureRecognizer *tapGestureRecognizer;
}

- (NSInteger)calcPosterImageSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UIPanGestureRecognizer *)gr;

@end

@implementation DCGroupView

@synthesize delegate = _delegate;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize posterImageSize = _posterImageSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize posterImage = _posterImage;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize enumDataItemParam = _enumDataItemParam;

- (void)refreshItems:(BOOL)force {
    if (self.dataLibraryHelper) {
        if (force || [self.dataLibraryHelper itemsCountInGroup:self.dataGroupUID] == 0) {
            [self.dataLibraryHelper clearCacheInGroup:self.dataGroupUID];
            [self.dataLibraryHelper enumItems:self.enumDataItemParam InGroup:self.dataGroupUID];
        }
    }
}

- (void)tap:(UIPanGestureRecognizer *)gr {
    NSLog(@"DCGroupView tap:");
    if (self.delegate && self.dataGroupUID) {
        [self.delegate selectGroup:self.dataGroupUID];
    }
}

- (void)dealloc {
    if (tapGestureRecognizer) {
        [self removeGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        tapGestureRecognizer = nil;
    }
    
    self.posterImage = nil;
    self.dataGroupUID = nil;
    self.enumDataItemParam = nil;
    self.dataLibraryHelper = nil;
    self.delegate = nil;
    
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
        if (self.posterImageSize == 0 || !self.dataGroupUID || !self.dataLibraryHelper) {
            break;
        }
        id <DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
        if (!group) {
            break;
        }
        CGRect bounds = [self bounds];
        
        self.posterImage = (UIImage *)[group valueForProperty:kDATAGROUPPROPERTY_POSTERIMAGE withOptions:nil];
        CGSize posterImageSize = [self.posterImage size];
        
        CGRect imageViewFrame;
        if (posterImageSize.width >= self.posterImageSize && posterImageSize.width > posterImageSize.height) {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0), bounds.origin.y + ((self.posterImageSize * (1.0 - posterImageSize.height / posterImageSize.width)) / 2.0), self.posterImageSize, (posterImageSize.height / posterImageSize.width * self.posterImageSize));
        } else if (posterImageSize.height >= self.posterImageSize) {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0)+ ((self.posterImageSize * (1.0 - posterImageSize.width / posterImageSize.height)) / 2.0), bounds.origin.y, (posterImageSize.width / posterImageSize.height * self.posterImageSize), self.posterImageSize);
        } else {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0) + ((self.posterImageSize - posterImageSize.width) / 2.0), bounds.origin.y + ((self.posterImageSize - posterImageSize.height) / 2.0), posterImageSize.width, posterImageSize.height);
        }
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
        [imageView setImage:self.posterImage];
        
        CGRect titleLabelFrame = CGRectMake(bounds.origin.x, bounds.origin.y + self.posterImageSize + GROUPVIEW_TITLELABEL_SPACE, bounds.size.width, GROUPVIEW_TITLELABEL_HEIGHT);
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:titleLabelFrame] autorelease];
        NSString *groupName = (NSString *)[group valueForProperty:kDATAGROUPPROPERTY_GROUPNAME withOptions:nil];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [titleLabel setText:[[[NSString alloc] initWithFormat:@"%@", groupName] autorelease]];
        
        CGRect numberLabelFrame = CGRectMake(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y, bounds.size.width / 2.0, GROUPVIEW_TITLELABEL_HEIGHT);
        UILabel *numbereLabel = [[[UILabel alloc] initWithFrame:numberLabelFrame] autorelease];
        NSInteger numberOfItems = [group itemsCount];
        [numbereLabel setBackgroundColor:[UIColor clearColor]];
		[numbereLabel setTextColor:[UIColor whiteColor]];
		numbereLabel.textAlignment = UITextAlignmentRight;
		numbereLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [numbereLabel setText:[[[NSString alloc] initWithFormat:@"%d", numberOfItems] autorelease]];
        
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
