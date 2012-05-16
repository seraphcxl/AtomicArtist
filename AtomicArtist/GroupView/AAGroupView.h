//
//  AAGroupView.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAGroupViewDelegate <NSObject>

- (void)selectGroup:(NSString *)groupPersistentID;

@end

@interface AAGroupView : UIView

@property (assign, nonatomic) id <AAGroupViewDelegate> delegate;
@property (retain, nonatomic) NSString *groupPersistentID;
@property (readonly, nonatomic) NSUInteger posterImageSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *posterImage;

- (void)refreshAssets:(BOOL)force;

@end
