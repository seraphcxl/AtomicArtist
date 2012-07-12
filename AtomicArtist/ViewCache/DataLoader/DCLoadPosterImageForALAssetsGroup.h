//
//  DCLoadPosterImageForALAssetsGroup.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCLoadPosterImageOperation.h"

@interface DCLoadPosterImageForALAssetsGroup : DCLoadPosterImageOperation

@property (readonly, nonatomic) ALAsset *alAsset;

- (id)initWithItemUID:(NSString *)itemUID dataGroupUID:(NSString *)dataGroupUID andALAsset:(ALAsset *)alAsset;

@end
