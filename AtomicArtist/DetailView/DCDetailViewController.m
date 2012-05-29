//
//  DCDetailViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCDetailViewController.h"
#import "DCImageHelper.h"

@interface DCDetailViewController () {
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
//    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
//    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    
    DETAILIMAGEVIEWTYPE _imageViewType;
    
    UIImage *_fitInImage;
    UIImage *_originImage;
}

- (void)tap:(UITapGestureRecognizer *)gr;

- (void)relayout;

- (void)changeDetailImageViewType;

- (void)clearUI;

@end

@implementation DCDetailViewController

@synthesize delegate = _delegate;
@synthesize currentDataGroupUID = _currentDataGroupUID;
@synthesize currentItemUID = _currentItemUID;
@synthesize currentIndexInGroup = _currentIndexInGroupp;
@synthesize imageView = _imageView;
@synthesize imageScrollView = _imageScrollView;
@synthesize dataLibraryHelper =_dataLibraryHelper;

- (void)clearUI {
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
}

- (void)changeDetailImageViewType {
    if (_imageViewType == DETAILIMAGEVIEWTYPE_FITIN) {
        if (self.imageView) {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
        }
        
        if (!_originImage) {
            if (self.currentItemUID && self.currentDataGroupUID) {
                if (self.dataLibraryHelper) {
                    id <DCDataItem> item = [self.dataLibraryHelper itemWithUID:self.currentItemUID inGroup:self.currentDataGroupUID];
                    if (item) {
                        _originImage = (UIImage *)[item valueForProperty:kDATAITEMPROPERTY_ORIGINIMAGE withOptions:nil];
                        [_originImage retain];
                    }
                } else {
                    [NSException raise:@"DCDetailViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
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
        
//        if (_swipeRightGestureRecognizer) {
//            [self.view removeGestureRecognizer:_swipeRightGestureRecognizer];
//            [_swipeRightGestureRecognizer release];
//            _swipeRightGestureRecognizer = nil;
//        }
//        if (_swipeLeftGestureRecognizer) {
//            [self.view removeGestureRecognizer:_swipeLeftGestureRecognizer];
//            [_swipeLeftGestureRecognizer release];
//            _swipeLeftGestureRecognizer = nil;
//        }
    } else if (_imageViewType == DETAILIMAGEVIEWTYPE_ORIGIN) {
        [self relayout];
    } else {
        [NSException raise:@"AADetailViewController error" format:@"Reason: _imageViewType unknown"];
    }
    
    if (self.delegate) {
        [self.delegate detailImageViewTypeChanged:_imageViewType];
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
        if (self.currentItemUID && self.currentDataGroupUID) {
            if (self.dataLibraryHelper) {
                id <DCDataItem> item = [self.dataLibraryHelper itemWithUID:self.currentItemUID inGroup:self.currentDataGroupUID];
                if (item) {
                    UIImage *fullScreemImage = (UIImage *)[item valueForProperty:kDATAITEMPROPERTY_FULLSCREENIMAGE withOptions:nil];
                    _fitInImage = [DCImageHelper image:fullScreemImage fitInSize:rect.size];
                    [_fitInImage retain];
                    NSString *fileName = (NSString *)[item valueForProperty:kDATAITEMPROPERTY_FILENAME withOptions:nil];
                    [self.navigationItem setTitle:fileName];
                }
            } else {
                [NSException raise:@"DCDetailViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
            } 
        }
    }
    
    [self.imageView setBackgroundColor:[UIColor clearColor]];
    [self.imageView setImage:_fitInImage];
    [self.imageScrollView addSubview:self.imageView];
    _imageViewType = DETAILIMAGEVIEWTYPE_FITIN;
    
//    if (!_swipeRightGestureRecognizer) {
//        _swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//        _swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        [self.view addGestureRecognizer:_swipeRightGestureRecognizer];
//    }
//    if (!_swipeLeftGestureRecognizer) {
//        _swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//        _swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        [self.view addGestureRecognizer:_swipeLeftGestureRecognizer];
//    }
}

- (void)tap:(UITapGestureRecognizer *)gr {
    if (gr == _doubleTapGestureRecognizer && gr.numberOfTapsRequired == 2) {
        NSLog(@"AADetailViewController tap:double");
        [self changeDetailImageViewType];
    } else {
        ;
    }
}

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper dataGroupUID:(NSString *)dataGroupUID itemUID:(NSString *)itemUID andIndexInGroup:(NSUInteger)indexInGroup {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.dataLibraryHelper = dataLibraryHelper;
        self.currentDataGroupUID = dataGroupUID;
        self.currentItemUID = itemUID;
        self.currentIndexInGroup = indexInGroup;
        
        if (!_doubleTapGestureRecognizer) {
            _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [self.view addGestureRecognizer:_doubleTapGestureRecognizer];
        }
        
//        if (!_swipeRightGestureRecognizer) {
//            _swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//            _swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//            [self.view addGestureRecognizer:_swipeRightGestureRecognizer];
//        }
//        if (!_swipeLeftGestureRecognizer) {
//            _swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//            _swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//            [self.view addGestureRecognizer:_swipeLeftGestureRecognizer];
//        }
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
    
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self relayout];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_fitInImage) {
        [_fitInImage release];
        _fitInImage = nil;
    }
    
    if (_originImage) {
        [_originImage release];
        _originImage = nil;
    }
    [self clearUI];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
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
    BOOL needRotate = NO;
    if (self.imageScrollView) {
        CGRect rectForScrollView = [self.imageScrollView bounds];
        CGRect rectForView = [self.view bounds];
        if (rectForView.size.width != rectForScrollView.size.width) {
            needRotate = YES;
        }
    }
    if (needRotate) {
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
    
    return result;
}

- (void)dealloc {
//    if (_swipeRightGestureRecognizer) {
//        [self.view removeGestureRecognizer:_swipeRightGestureRecognizer];
//        [_swipeRightGestureRecognizer release];
//        _swipeRightGestureRecognizer = nil;
//    }
//    
//    if (_swipeLeftGestureRecognizer) {
//        [self.view removeGestureRecognizer:_swipeLeftGestureRecognizer];
//        [_swipeLeftGestureRecognizer release];
//        _swipeLeftGestureRecognizer = nil;
//    }
    
    if (_doubleTapGestureRecognizer) {
        [self.view removeGestureRecognizer:_doubleTapGestureRecognizer];
        [_doubleTapGestureRecognizer release];
        _doubleTapGestureRecognizer = nil;
    }
    
    [self clearUI];
    
    self.currentDataGroupUID = nil;
    self.currentItemUID = nil;
    self.dataLibraryHelper = nil;
    
    [super dealloc];
}

@end
