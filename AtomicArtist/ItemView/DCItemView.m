//
//  DCItemView.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCItemView.h"
#import "DCDataModelHelper.h"
#import "Item.h"
#import "DCDataLoader.h"

@interface DCItemView () {
    UITapGestureRecognizer *_singleTapGestureRecognizer;
}

- (NSInteger)calcThumbnailSize;

- (NSInteger)calcTitleFontSize;

- (void)tap:(UITapGestureRecognizer *)gr;

- (void)runOperation;

- (void)loadDBThumbnail;

- (void)showThumbnail;

@end


@implementation DCItemView

@synthesize delegate = _delegate;
@synthesize itemUID = _itemUID;
@synthesize thumbnailSize = _thumbnailSize;
@synthesize titleFontSize = _titleFontSize;
@synthesize thumbnail = _thumbnail;
@synthesize dataGroupUID = _dataGroupUID;
@synthesize dataLibraryHelper = _dataLibraryHelper;
@synthesize loadThumbnailOperation = _loadThumbnailOperation;

- (void)showThumbnail {
    do {
        if (!self.thumbnail) {
            break;
        }
        CGRect bounds = [self bounds];
        
        CGSize thumbnailSize = [self.thumbnail size];
        
        if (thumbnailSize.width == 0 || thumbnailSize.height == 0) {
            break;
        }
        
        CGRect imageViewFrame;
        
        if (thumbnailSize.width > thumbnailSize.height) {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0), bounds.origin.y + ((self.thumbnailSize * (1.0 - thumbnailSize.height / thumbnailSize.width)) / 2.0), self.thumbnailSize, (thumbnailSize.height / thumbnailSize.width * self.thumbnailSize));
        } else {
            imageViewFrame = CGRectMake(bounds.origin.x + ((GROUPVIEW_TITLELABEL_HEIGHT + GROUPVIEW_TITLELABEL_SPACE) / 2.0)+ ((self.thumbnailSize * (1.0 - thumbnailSize.width / thumbnailSize.height)) / 2.0), bounds.origin.y, (thumbnailSize.width / thumbnailSize.height * self.thumbnailSize), self.thumbnailSize);
        }
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewFrame] autorelease];
        [imageView setImage:self.thumbnail];
        
        for (UIView *view in self.subviews) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        [self addSubview:imageView];
    } while (NO);
}

- (void)loadDBThumbnail {
    BOOL needRunOperation = NO;
    Item *dataModelItem = [[DCDataModelHelper defaultDataModelHelper] getItemWithUID:self.itemUID];
    if (!dataModelItem) {
        needRunOperation = YES;
    } else {
        self.thumbnail = dataModelItem.thumbnail;
        if (!self.thumbnail) {
            needRunOperation = YES;
        }
    }
    if (needRunOperation) {
        [self performSelectorOnMainThread:@selector(runOperation) withObject:nil waitUntilDone:NO];
    } else {
        [self showThumbnail];
    }
}

- (void)updateThumbnail {
    [self performSelectorOnMainThread:@selector(showThumbnail) withObject:nil waitUntilDone:NO];
}

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
    
    if (_loadThumbnailOperation) {
        [_loadThumbnailOperation cancel];
        [_loadThumbnailOperation release];
        _loadThumbnailOperation = nil;
    }
    
    self.dataLibraryHelper = nil;
    self.thumbnail = nil;
    
    if (_itemUID) {
        [_itemUID release];
        _itemUID = nil;
    }
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

- (void)runOperation {
    if (self.loadThumbnailOperation) {
//        [self.loadThumbnailOperation start];
    } else {
        id <DCDataItem> item = [self.dataLibraryHelper itemWithUID:self.itemUID inGroup:self.dataGroupUID];
        if (!item) {
            return;
        }
        _loadThumbnailOperation = [item createOperationForLoadCacheThumbnail];
        [_loadThumbnailOperation retain];
        [[DCDataLoader defaultDataLoader] queue:DATALODER_TYPE_VISIABLE addOperation:self.loadThumbnailOperation];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    do {
        if (self.thumbnailSize == 0 || !self.itemUID) {
            break;
        }
        
        if (self.dataLibraryHelper) {
            BOOL needRunOperation = NO;
            
            if (!self.thumbnail) {
                id <DCDataItem> item = [self.dataLibraryHelper itemWithUID:self.itemUID inGroup:self.dataGroupUID];
                if (!item) {
                    break;
                }
                self.thumbnail = (UIImage *)[item valueForProperty:kDATAITEMPROPERTY_THUMBNAIL withOptions:nil];
                needRunOperation = YES;
            } else {
                if (self.thumbnail.size.width >= self.thumbnailSize || self.thumbnail.size.height >= self.thumbnailSize) {
                    needRunOperation = NO;
                } else {
                    needRunOperation = YES;
                }
            }
            
            if (needRunOperation) {
                [self performSelectorOnMainThread:@selector(loadDBThumbnail) withObject:nil waitUntilDone:NO];
            }
            [self showThumbnail];
        } else {
            [NSException raise:@"DCItemView error" format:@"Reason: self.dataLibraryHelper == nil"];
        }
    } while (NO);
}

- (id)InitWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper itemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _thumbnailSize = [self calcThumbnailSize];
        _titleFontSize = [self calcTitleFontSize];
        _itemUID = itemUID;
        [_itemUID retain];
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
