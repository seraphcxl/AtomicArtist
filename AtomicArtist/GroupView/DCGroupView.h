//
//  DCGroupView.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUniformDataProtocol.h"

@protocol DCGroupViewDelegate <NSObject>

- (void)selectGroup:(NSString *)dataGroupUID;

@end

@interface DCGroupView : UIView

@property (assign, nonatomic) id <DCGroupViewDelegate> delegate;
@property (retain, nonatomic) NSString *dataGroupUID;
@property (readonly, nonatomic) NSUInteger posterImageSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *posterImage;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (assign, nonatomic) id enumDataItemParam;
@property (readonly, nonatomic) NSOperation *loadPosterImageOperation;

- (void)refreshItems:(BOOL)force;

- (void)cancelLoadPosterImageOperation;

@end
