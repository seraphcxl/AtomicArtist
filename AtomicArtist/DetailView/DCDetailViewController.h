//
//  DCDetailViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>

enum DETAILIMAGEVIEWTYPE {
    DETAILIMAGEVIEWTYPE_FITIN = 0x00000000,
    DETAILIMAGEVIEWTYPE_ORIGIN = 0x000000001,
    };

@interface DCDetailViewController : UIViewController

@property (retain, nonatomic) NSString *currentGroupPersistentID;
@property (retain, nonatomic) NSURL *currentAssetURL;
@property (assign, nonatomic) NSUInteger currentAssetIndexInGroup;
@property (assign, nonatomic) UIScrollView *imageScrollView;
@property (retain, nonatomic) UIImageView *imageView;

- (id)initWithGroupPersistentID:(NSString *)groupPersistentID assetURL:(NSURL *)assetURL andAssetIndexInGroup:(NSUInteger) assetIndexInGroup;

- (void)next;

- (void)previous;

@end
