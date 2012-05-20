//
//  DCDetailViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUniformDataProtocol.h"

typedef enum {
    DETAILIMAGEVIEWTYPE_FITIN = 0x00000000,
    DETAILIMAGEVIEWTYPE_ORIGIN = 0x000000001,
} DETAILIMAGEVIEWTYPE;

@protocol DCDetailViewControllerDelegate <NSObject>

-(void)detailImageViewTypeChanged:(DETAILIMAGEVIEWTYPE)type;

@end

@interface DCDetailViewController : UIViewController

@property (assign, nonatomic) id <DCDetailViewControllerDelegate> delegate;
@property (retain, nonatomic) NSString *currentDataGroupUID;
@property (retain, nonatomic) NSString *currentItemUID;
@property (assign, nonatomic) NSUInteger currentIndexInGroup;
@property (assign, nonatomic) UIScrollView *imageScrollView;
@property (retain, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;

- (id)initWithDataLibraryHelper:(id <DCDataLibraryHelper>)dataLibraryHelper dataGroupUID:(NSString *)dataGroupUID itemUID:(NSString *)itemUID andIndexInGroup:(NSUInteger) indexInGroup;

@end
