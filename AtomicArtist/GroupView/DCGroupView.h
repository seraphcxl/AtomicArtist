//
//  DCGroupView.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCGroupViewDelegate <NSObject>

- (void)selectGroup:(NSString *)groupPersistentID;

@end

@interface DCGroupView : UIView

@property (assign, nonatomic) id <DCGroupViewDelegate> delegate;
@property (retain, nonatomic) NSString *groupPersistentID;
@property (readonly, nonatomic) NSUInteger posterImageSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *posterImage;

- (void)refreshAssets:(BOOL)force;

@end
