//
//  DCItemView.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUniformDataProtocol.h"

@protocol DCItemViewDelegate <NSObject>

- (void)selectItem:(NSString *)itemUID;

@end

@interface DCItemView : UIView

@property (assign, nonatomic) id <DCItemViewDelegate> delegate;
@property (readonly, nonatomic) NSString *itemUID;
@property (readonly, nonatomic) NSUInteger thumbnailSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *thumbnail;
@property (readonly, nonatomic) NSString *dataGroupUID;
@property (assign, nonatomic) id <DCDataLibraryHelper> dataLibraryHelper;
@property (retain, nonatomic) NSOperation *loadThumbnailOperation;

- (id)InitWithDataLibraryHelper:(id <DCDataLibraryHelper>)dataLibraryHelper itemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID andFrame:(CGRect)frame;

@end
