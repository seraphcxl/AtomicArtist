//
//  AAItemView.h
//  AtomicArtist
//
//  Created by XiaoLiang Chen on 5/5/12.
//  Copyright (c) 2012 ZheJiang University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAItemViewDelegate <NSObject>

- (void)selectItem:(NSURL *)assetURL;

@end

@interface AAItemView : UIView

@property (assign, nonatomic) id <AAItemViewDelegate> delegate;
@property (retain, nonatomic) NSURL *assetURL;
@property (readonly, nonatomic) NSUInteger thumbnailSize;
@property (readonly, nonatomic) NSUInteger titleFontSize;
@property (retain, nonatomic) UIImage *thumbnail;
@property (readonly, nonatomic) NSString *groupPersistentID;

- (id)InitWithGroupPersistentID:(NSString *)groupPersistentID andFrame:(CGRect)frame;

@end
