//
//  DCDetailViewController.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCDetailViewController.h"
#import "DCImageHelper.h"

#define TIMEFORHIDEASSIST ((NSTimeInterval)2.0)

@interface DCDetailViewController () {
    NSTimer *_timerForHideAssist;
    
    UITapGestureRecognizer *_singleTapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
//    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
//    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    
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

@synthesize currentDataGroupUID = _currentDataGroupUID;
@synthesize currentItemUID = _currentItemUID;
@synthesize currentIndexInGroup = _currentIndexInGroupp;
@synthesize imageView = _imageView;
@synthesize imageScrollView = _imageScrollView;
@synthesize dataLibraryHelper =_dataLibraryHelper;

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
    self.currentDataGroupUID = nil;
    self.currentItemUID = nil;
}

- (void)next {
    if (self.dataLibraryHelper) {
        NSUInteger count = [self.dataLibraryHelper itemsCountInGroup:self.currentDataGroupUID];
        if (self.currentIndexInGroup < (count - 1)) {
            NSString *currentDataGroupUID = self.currentDataGroupUID;
            [currentDataGroupUID retain];
            NSUInteger currentIndex = ++self.currentIndexInGroup;
            // clear current information
            [self clearCurrentInfomation];
            // get next information
            NSString *currentItemUID = [self.dataLibraryHelper itemUIDAtIndex:currentIndex inGroup:currentDataGroupUID];
            [currentItemUID retain];
            
            [self initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:currentDataGroupUID itemUID:currentItemUID andIndexInGroup:currentIndex];
            
            [currentItemUID release];
            currentItemUID = nil;
            [currentDataGroupUID release];
            currentDataGroupUID = nil;
            
            [self relayout];
            
        } else {
            NSLog(@"last asset in group");
        }
    } else {
        [NSException raise:@"DCDetailViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
}

- (void)previous {
    if (self.dataLibraryHelper) {
        if (self.currentIndexInGroup != 0) {
            NSString *currentDataGroupUID = self.currentDataGroupUID;
            [currentDataGroupUID retain];
            NSUInteger currentIndex = --self.currentIndexInGroup;
            // clear current information
            [self clearCurrentInfomation];
            // get prev information
            NSString *currentItemUID = [self.dataLibraryHelper itemUIDAtIndex:currentIndex inGroup:currentDataGroupUID];
            [currentItemUID retain];
            
            [self initWithDataLibraryHelper:self.dataLibraryHelper dataGroupUID:currentDataGroupUID itemUID:currentItemUID andIndexInGroup:currentIndex];
            
            [currentItemUID release];
            currentItemUID = nil;
            [currentDataGroupUID release];
            currentDataGroupUID = nil;
            
            [self relayout];
            
        } else {
            NSLog(@"last asset in group");
        }
    } else {
        [NSException raise:@"DCDetailViewController error" format:@"Reason: self.dataLibraryHelper == nil"];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)gr {
    NSLog(@"AADetailViewController swipes:");
//    if (gr == _swipeRightGestureRecognizer) {
//        if ([gr direction] == UISwipeGestureRecognizerDirectionRight) {
//            [self previous];
//        } else {
//            [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
//        }
//    } else if (gr == _swipeLeftGestureRecognizer) {
//        if ([gr direction] == UISwipeGestureRecognizerDirectionLeft) {
//            [self next];
//        } else {
//            [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
//        }
//    } else {
//        [NSException raise:@"AADetailViewController error" format:@"Reason: direction not supported"];
//    }
}

- (void)showOriginImage {
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

- (id)initWithDataLibraryHelper:(id<DCDataLibraryHelper>)dataLibraryHelper dataGroupUID:(NSString *)dataGroupUID itemUID:(NSString *)itemUID andIndexInGroup:(NSUInteger)indexInGroup {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.dataLibraryHelper = dataLibraryHelper;
        self.currentDataGroupUID = dataGroupUID;
        self.currentItemUID = itemUID;
        self.currentIndexInGroup = indexInGroup;
        
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
    [self.navigationController.navigationBar setHidden:YES];
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
    
    if (_singleTapGestureRecognizer) {
        [self.view removeGestureRecognizer:_singleTapGestureRecognizer];
        [_singleTapGestureRecognizer release];
        _singleTapGestureRecognizer = nil;
    }
    
    [self clearCurrentInfomation];
    
    self.dataLibraryHelper = nil;
    
    [super dealloc];
}

@end
