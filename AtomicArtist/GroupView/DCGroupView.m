//
//  DCGroupView.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCGroupView.h"
#import "DCDataModelHelper.h"
#import "Group.h"
#import "DCDataLoader.h"

@interface DCGroupView () {
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    CGFloat _pinchScale;
    
    BOOL _loadBigThumbnailInVisiableDataLoader;
    BOOL _loadBigThumbnailInBufferDataLoader;
}

- (NSInteger)calcPosterImageSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UITapGestureRecognizer *)gr;
- (void)pinch:(UIPinchGestureRecognizer *)gr;

- (void)preparePosterImageInfo;

- (void)runOperation:(NSNotification *)note;

- (void)loadDBPosterImage;

- (void)showPosterImage;

- (void)refreshItemsForPosterImage:(BOOL)force;

@end

@implementation DCGroupView

@synthesize delegate = _delegate;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize posterImageSize = _posterImageSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize posterImage = _posterImage;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize enumDataItemParam = _enumDataItemParam;

- (void)loadSmallThumbnail {
    do {
        if (!self.posterImage) {
            if (!self.dataGroupUID || !self.dataLibraryHelper) {
                break;
            }
            id <DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
            if (!group) {
                break;
            }
            
            self.posterImage = (UIImage *)[group valueForProperty:kDATAGROUPPROPERTY_POSTERIMAGE withOptions:nil];
        }
    } while (NO);
}

- (void)loadBigThumbnailInQueue:(enum DATALODER_TYPE)type {
    do {
        if (!self.posterImage || (self.posterImage.size.width < self.posterImageSize && self.posterImage.size.height < self.posterImageSize)) {
            switch (type) {
                case DATALODER_TYPE_VISIABLE:
                    _loadBigThumbnailInVisiableDataLoader = YES;
                    break;
                    
                case DATALODER_TYPE_BUFFER:
                    _loadBigThumbnailInBufferDataLoader = YES;
                    break;
                    
                default:
                    break;
            }
            
            [self loadDBPosterImage];
        }
    } while (NO);
}

- (void)showPosterImage {
    do {
        if (!self.posterImage) {
            break;
        }
        CGRect bounds = [self bounds];
        
        CGSize posterImageSize = [self.posterImage size];
        
        if (posterImageSize.width == 0 || posterImageSize.height == 0) {
            break;
        }
        
        CGRect imageViewFrame;
        if (posterImageSize.width > posterImageSize.height) {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0), bounds.origin.y + ((self.posterImageSize * (1.0 - posterImageSize.height / posterImageSize.width)) / 2.0), self.posterImageSize, (posterImageSize.height / posterImageSize.width * self.posterImageSize));
        } else {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0)+ ((self.posterImageSize * (1.0 - posterImageSize.width / posterImageSize.height)) / 2.0), bounds.origin.y, (posterImageSize.width / posterImageSize.height * self.posterImageSize), self.posterImageSize);
        }
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
        [imageView setImage:self.posterImage];
        
        for (UIView *view in self.subviews) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        [self addSubview:imageView];
    } while (NO);
}

- (void)loadDBPosterImage {
    BOOL needRunOperation = NO;
    Group *dataModelGroup = [[DCDataModelHelper defaultDataModelHelper] getGroupWithUID:self.dataGroupUID];
    if (!dataModelGroup) {
        needRunOperation = YES;
    } else {
        self.posterImage = dataModelGroup.posterImage;
        if (!self.posterImage) {
            needRunOperation = YES;
        }
    }
    if (needRunOperation) {
        [self preparePosterImageInfo];
    } else {
        [self performSelectorOnMainThread:@selector(showPosterImage) withObject:nil waitUntilDone:NO];
    }
}

- (void)updatePosterImage {
    [self performSelectorOnMainThread:@selector(showPosterImage) withObject:nil waitUntilDone:NO];
}

- (void)refreshItemsForPosterImage:(BOOL)force {
    if (self.dataLibraryHelper) {
        if (force || ![self.dataLibraryHelper isGroupEnumerated:self.dataGroupUID]) {
            if ([self.dataLibraryHelper itemsCountWithParam:self.enumDataItemParam inGroup:self.dataGroupUID] != 0) {
                [self.dataLibraryHelper clearCacheInGroup:self.dataGroupUID];
                NSIndexSet *indexSet = [[[NSIndexSet alloc] initWithIndex:0] autorelease];
                [self.dataLibraryHelper enumItemAtIndexes:indexSet withParam:self.enumDataItemParam inGroup:self.dataGroupUID notifyWithFrequency:1];
            }
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)gr {
    NSLog(@"DCGroupView tap:");
    if (self.delegate && self.dataGroupUID) {
        [self.delegate selectGroup:self.dataGroupUID];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gr {
    NSLog(@"DCGroupView pinch:");
    if (gr.state == UIGestureRecognizerStateBegan) {
        _pinchScale = gr.scale;
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        if (gr.scale > _pinchScale) {
            [self tap:nil];
        }
        _pinchScale = 0.0;
    }
}

- (void)dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    if (_tapGestureRecognizer) {
        [self removeGestureRecognizer:_tapGestureRecognizer];
        [_tapGestureRecognizer release];
        _tapGestureRecognizer = nil;
    }
    
    if (_pinchGestureRecognizer) {
        _pinchScale = 0.0;
        [self removeGestureRecognizer:_pinchGestureRecognizer];
        [_pinchGestureRecognizer release];
        _pinchGestureRecognizer = nil;
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

- (void)preparePosterImageInfo {
    if (self.dataLibraryHelper) {
        [self refreshItemsForPosterImage:NO];
        
    } else {
        [NSException raise:@"DCGroupView error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
}

- (void)runOperation:(NSNotification *)note {
    do {
        if (note) {
            NSString *dataGroupUID = (NSString *)[note object];
            if ([dataGroupUID isEqualToString:self.dataGroupUID]) {
                NSString *itemUID = [self.dataLibraryHelper itemUIDAtIndex:0 inGroup:self.dataGroupUID];
                id <DCDataGroup> group = [self.dataLibraryHelper groupWithUID:self.dataGroupUID];
                if (!group) {
                    break;
                }
                
                if (_loadBigThumbnailInVisiableDataLoader) {
                    _loadBigThumbnailInVisiableDataLoader = NO;
                    NSOperation *loadPosterImageOperation = [group createOperationForLoadCachePosterImageWithItemUID:itemUID];
                    [[DCDataLoader defaultDataLoader] queue:DATALODER_TYPE_VISIABLE addOperation:loadPosterImageOperation];
                }
                
                if (_loadBigThumbnailInBufferDataLoader) {
                    _loadBigThumbnailInBufferDataLoader = NO;
                    NSOperation *loadPosterImageOperation = [group createOperationForLoadCachePosterImageWithItemUID:itemUID];
                    [[DCDataLoader defaultDataLoader] queue:DATALODER_TYPE_BUFFER addOperation:loadPosterImageOperation];
                }
            }
        }
    } while (NO);
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
        
        [self showPosterImage];

        CGRect bounds = [self bounds];
        
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
        NSInteger numberOfItems = [group itemsCountWithParam:self.enumDataItemParam];
        [numbereLabel setBackgroundColor:[UIColor clearColor]];
		[numbereLabel setTextColor:[UIColor whiteColor]];
		numbereLabel.textAlignment = UITextAlignmentRight;
		numbereLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [numbereLabel setText:[[[NSString alloc] initWithFormat:@"%d", numberOfItems] autorelease]];
        
        for (UIView *view in self.subviews) {
            if ([view isMemberOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        
        [self addSubview:titleLabel];
        [self addSubview:numbereLabel];
    } while (NO);
}

- (id)InitWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper dataGroupUID:(NSString *)dataGroupUID enumDataItemParam:(id)enumDataItemParam andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataLibraryHelper = dataLibraryHelper;
        self.dataGroupUID = dataGroupUID;
        self.enumDataItemParam = enumDataItemParam;
        
        _loadBigThumbnailInVisiableDataLoader = NO;
        _loadBigThumbnailInBufferDataLoader = NO;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _posterImageSize = [self calcPosterImageSize];
        _titleFontSize = [self calcTitleFontSize];
        
        if (!_tapGestureRecognizer) {
            _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self addGestureRecognizer:_tapGestureRecognizer];
        }
        
        if (!_pinchGestureRecognizer) {
            _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            [self addGestureRecognizer:_pinchGestureRecognizer];
            _pinchScale = 0.0;
        }
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(runOperation:) name:NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED object:nil];
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
