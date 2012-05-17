//
//  DCItemView.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCItemViewDelegate <NSObject>

- (void)selectItem:(NSURL *)assetURL;

@end

@interface DCItemView : UIView

@property (assign, nonatomic) id <DCItemViewDelegate> delegate;
@property (retain, nonatomic) NSURL *assetURL;
@property (readonly, nonatomic) NSUInteger thumbnailSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *thumbnail;
@property (readonly, nonatomic) NSString *groupPersistentID;

- (id)InitWithGroupPersistentID:(NSString *)groupPersistentID andFrame:(CGRect)frame;

@end
