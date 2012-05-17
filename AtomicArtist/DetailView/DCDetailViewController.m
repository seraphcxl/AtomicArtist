//
//  DCDetailViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCDetailViewController.h"
#import "DCAssetLibHelper.h"
#import "DCImageHelper.h"

#define TIMEFORHIDEASSIST ((NSTimeInterval)2.0)

@interface DCDetailViewController () {
    NSTimer *_timerForHideAssist;
    
    UITapGestureRecognizer *_singleTapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    
    enum DETAILIMAGEVIEWTYPE _imageViewType;
    
    UIImage *_fitInImage;
    UIImage *_originImage;
}

- (void)tap:(UITapGestureRecognizer *)gr;

- (void)swipe:(UIPanGestureRecognizer *)gr;

- (void)hideAssist:(NSTimer *)timer;

- (void)relayout;

- (void)showOriginImage;

- (void)clearCurrentInfomation;

@end

@implementation DCDetailViewController

@synthesize currentGroupPersistentID = _currentGroupPersistentID;
@synthesize currentAssetURL = _currentAssetURL;
@synthesize currentAssetIndexInGroup = _currentAssetIndexInGroup;
@synthesize imageView = _imageView;
@synthesize imageScrollView = _imageScrollView;

- (void)clearCurrentInfomation {
    if (_timerForHideAssist) {
        [_timerForHideAssist invalidate];
        [_timerForHideAssist release];
        _timerForHideAssist = nil;
    }
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    if (self.imageScrollView) {
        [self.imageScrollView removeFromSuperview];
        self.imageScrollView = nil;
    }
    if (_fitInImage) {
        [_fitInImage release];
        _fitInImage = nil;
    }
    if (_originImage) {
        [_originImage release];
        _originImage = nil;
    }
    self.currentGroupPersistentID = nil;
    self.currentAssetURL = nil;
}

- (void)next {
    DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
    NSUInteger count = [assetLibHelper assetCountForGroupWithPersistentID:self.currentGroupPersistentID];
    if (self.currentAssetIndexInGroup < (count - 1)) {
        NSString *currentGroupPersistentID = self.currentGroupPersistentID;
        [currentGroupPersistentID retain];
        NSUInteger currentIndex = ++self.currentAssetIndexInGroup;
        // clear current information
        [self clearCurrentInfomation];
        // get next information
        NSURL *currentAssetURL = [assetLibHelper getAssetURLForGoupPersistentID:currentGroupPersistentID atIndex:currentIndex];
        [currentAssetURL retain];
        
        [self initWithGroupPersistentID:currentGroupPersistentID assetURL:currentAssetURL andAssetIndexInGroup:currentIndex];
        
        [currentAssetURL release];
        currentAssetURL = nil;
        [currentGroupPersistentID release];
        currentGroupPersistentID = nil;
        
        [self relayout];
        
    } else {
        NSLog(@"last asset in group");
    }
}

- (void)previous {
    DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
    if (self.currentAssetIndexInGroup != 0) {
        NSString *currentGroupPersistentID = self.currentGroupPersistentID;
        [currentGroupPersistentID retain];
        NSUInteger currentIndex = --self.currentAssetIndexInGroup;
        // clear current information
        [self clearCurrentInfomation];
        // get next information
        NSURL *currentAssetURL = [assetLibHelper getAssetURLForGoupPersistentID:currentGroupPersistentID atIndex:currentIndex];
        [currentAssetURL retain];
        
        [self initWithGroupPersistentID:currentGroupPersistentID assetURL:currentAssetURL andAssetIndexInGroup:currentIndex];
        
        [currentAssetURL release];
        currentAssetURL = nil;
        [currentGroupPersistentID release];
        currentGroupPersistentID = nil;
        
        [self relayout];
        
    } else {
        NSLog(@"last asset in group");
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)gr {
    NSLog(@"AADetailViewController swipes:");
    if (gr == _swipeRightGestureRecognizer) {
        if ([gr direction] == UISwipeGestureRecognizerDirectionRight) {
            [self previous];
        } else {
            [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
        }
    } else if (gr == _swipeLeftGestureRecognizer) {
        if ([gr direction] == UISwipeGestureRecognizerDirectionLeft) {
            [self next];
        } else {
            [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
        }
    } else {
        [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
    }
}

- (void)showOriginImage {
    if (_imageViewType == DETAILIMAGEVIEWTYPE_FITIN) {
        if (self.imageView) {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
        }
        
        if (!_originImage) {
            if (self.currentAssetURL && self.currentGroupPersistentID) {
                DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
                ALAsset *asset = [assetLibHelper getALAssetForGoupPersistentID:self.currentGroupPersistentID forAssetURL:self.currentAssetURL];
                if (asset) {
                    ALAssetRepresentation *representation = [asset defaultRepresentation];
                    if (representation) {
                        _originImage = [[[UIImage alloc] initWithCGImage:[representation fullResolutionImage]] autorelease];
                        [_originImage retain];
                    }
                }
            }
        }
        
        CGSize originImageSize = [_originImage size];
        self.imageView = [[[UIImageView alloc] initWithImage:_originImage] autorelease];
        
        if (self.imageScrollView) {
            [self.imageScrollView addSubview:self.imageView];
            [self.imageScrollView setContentSize:originImageSize];
            CGRect rect = [self.imageScrollView bounds];
            CGPoint offset;
            offset.x = (originImageSize.width - rect.size.width) / 2.0;
            offset.y = (originImageSize.height - rect.size.height) / 2.0;
            [self.imageScrollView setContentOffset:offset animated:NO];
            self.imageScrollView.scrollEnabled = YES;
            _imageViewType = DETAILIMAGEVIEWTYPE_ORIGIN;
        } else {
            [NSException raise:@"AADetailViewController error" format:@"Reason: self.imageScrollView is nil when show origin image"];
        }
        if (_swipeRightGestureRecognizer) {
            [self.view removeGestureRecognizer:_swipeRightGestureRecognizer];
            [_swipeRightGestureRecognizer release];
            _swipeRightGestureRecognizer = nil;
        }
        if (_swipeLeftGestureRecognizer) {
            [self.view removeGestureRecognizer:_swipeLeftGestureRecognizer];
            [_swipeLeftGestureRecognizer release];
            _swipeLeftGestureRecognizer = nil;
        }
    } else if (_imageViewType == DETAILIMAGEVIEWTYPE_ORIGIN) {
        [self relayout];
    } else {
        [NSException raise:@"AADetailViewController error" format:@"Reason: _imageViewType unknown"];
    }
    
    
}

- (void)relayout {
    CGRect rect = [self.view bounds];
    
    if (self.imageScrollView) {
        CGRect imageScrollViewRect = [self.imageScrollView bounds];
        if (memcmp(&rect, &imageScrollViewRect, sizeof(CGRect)) != 0) {
            [self.imageScrollView removeFromSuperview];
            self.imageScrollView = nil;
        } else {
            return;
        }
    }
    
    if (!self.imageScrollView) {
        self.imageScrollView = [[[UIScrollView alloc] initWithFrame:rect] autorelease];
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.showsVerticalScrollIndicator = NO;
        //        self.imageScrollView.pagingEnabled = NO;
        [self.view addSubview:self.imageScrollView];
    }
    
    BOOL needAllocImageView = NO;
    if (self.imageView) {
        CGRect imageViewRect = [self.imageView bounds];
        if (memcmp(&rect, &imageViewRect, sizeof(CGRect)) != 0) {
            self.imageView = nil;
            needAllocImageView = YES;
        }
    } else {
        needAllocImageView = YES;
    }
    
    if (needAllocImageView) {
        self.imageView = [[[UIImageView alloc] initWithFrame:rect] autorelease];
    }
    
    if (!_fitInImage) {
        if (self.currentAssetURL && self.currentGroupPersistentID) {
            DCAssetLibHelper *assetLibHelper = [DCAssetLibHelper defaultAssetLibHelper];
            ALAsset *asset = [assetLibHelper getALAssetForGoupPersistentID:self.currentGroupPersistentID forAssetURL:self.currentAssetURL];
            if (asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                if (representation) {
                    UIImage *originImage = [[[UIImage alloc] initWithCGImage:[representation fullScreenImage]] autorelease];
                    _fitInImage = [DCImageHelper image:originImage fitInSize:rect.size];
                    [_fitInImage retain];
                    NSString *fileName = [representation filename];
                    [self.navigationItem setTitle:fileName];
                }
            }
        }
    }
    
    [self.imageView setBackgroundColor:[UIColor clearColor]];
    [self.imageView setImage:_fitInImage];
    [self.imageScrollView addSubview:self.imageView];
    _imageViewType = DETAILIMAGEVIEWTYPE_FITIN;
    
    if (!_swipeRightGestureRecognizer) {
        _swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:_swipeRightGestureRecognizer];
    }
    if (!_swipeLeftGestureRecognizer) {
        _swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:_swipeLeftGestureRecognizer];
    }
}

- (void)hideAssist:(NSTimer *)timer {
    NSLog(@"AADetailViewController hideAssist:");
    if (_timerForHideAssist == timer) {
        [self.navigationController.navigationBar setHidden:YES];
    }
}

- (void)tap:(UITapGestureRecognizer *)gr {
    if (gr == _singleTapGestureRecognizer && gr.numberOfTapsRequired == 1) {
        NSLog(@"AADetailViewController tap:single");
        
        [self.navigationController.navigationBar setHidden:NO];
        
        if (_timerForHideAssist) {
            [_timerForHideAssist invalidate];
            [_timerForHideAssist release];
            _timerForHideAssist = nil;
        }
        _timerForHideAssist = [NSTimer scheduledTimerWithTimeInterval:TIMEFORHIDEASSIST target:self selector:@selector(hideAssist:) userInfo:nil repeats:NO];
        [_timerForHideAssist retain];
    } else if (gr == _doubleTapGestureRecognizer && gr.numberOfTapsRequired == 2) {
        NSLog(@"AADetailViewController tap:double");
        [self showOriginImage];
    } else {
        ;
    }
    
    
}

- (id)initWithGroupPersistentID:(NSString *)groupPersistentID assetURL:(NSURL *)assetURL andAssetIndexInGroup:(NSUInteger)assetIndexInGroup {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.currentGroupPersistentID = groupPersistentID;
        self.currentAssetURL = assetURL;
        self.currentAssetIndexInGroup = assetIndexInGroup;
        
        if (!_singleTapGestureRecognizer) {
            _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            _singleTapGestureRecognizer.numberOfTapsRequired = 1;
            [self.view addGestureRecognizer:_singleTapGestureRecognizer];
        }
        
        if (!_doubleTapGestureRecognizer) {
            _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [self.view addGestureRecognizer:_doubleTapGestureRecognizer];
        }
        
        if (!_swipeRightGestureRecognizer) {
            _swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
            _swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            [self.view addGestureRecognizer:_swipeRightGestureRecognizer];
        }
        if (!_swipeLeftGestureRecognizer) {
            _swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
            _swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.view addGestureRecognizer:_swipeLeftGestureRecognizer];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if (_fitInImage) {
        [_fitInImage release];
        _fitInImage = nil;
    }
    
    if (_originImage) {
        [_originImage release];
        _originImage = nil;
    }
    
    [self relayout];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self clearCurrentInfomation];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL result = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        result =  (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        result =  YES;
    } else {
        [NSException raise:@"AADetailViewController error" format:@"Reason: Current device type unknown"];
        result =  NO;
    }
    
    if (_fitInImage) {
        [_fitInImage release];
        _fitInImage = nil;
    }
    
    if (_originImage) {
        [_originImage release];
        _originImage = nil;
    }
    
    [self relayout];
    
    return result;
}

- (void)dealloc {
    if (_swipeRightGestureRecognizer) {
        [self.view removeGestureRecognizer:_swipeRightGestureRecognizer];
        [_swipeRightGestureRecognizer release];
        _swipeRightGestureRecognizer = nil;
    }
    
    if (_swipeLeftGestureRecognizer) {
        [self.view removeGestureRecognizer:_swipeLeftGestureRecognizer];
        [_swipeLeftGestureRecognizer release];
        _swipeLeftGestureRecognizer = nil;
    }
    
    if (_doubleTapGestureRecognizer) {
        [self.view removeGestureRecognizer:_doubleTapGestureRecognizer];
        [_doubleTapGestureRecognizer release];
        _doubleTapGestureRecognizer = nil;
    }
    
    if (_singleTapGestureRecognizer) {
        [self.view removeGestureRecognizer:_singleTapGestureRecognizer];
        [_singleTapGestureRecognizer release];
        _singleTapGestureRecognizer = nil;
    }
    
    [self clearCurrentInfomation];
    
    [super dealloc];
}

@end
