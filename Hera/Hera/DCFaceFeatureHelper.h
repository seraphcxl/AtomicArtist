//
//  DCFaceFeatureHelper.h
//  Hera
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"
#import "DCSingletonTemplate.h"

extern NSString * const NOTIFY_FACEFEATURE_DETECTED;

extern NSString * const kFACEFEATURE_DATAITEM_UID;
extern NSString * const kFACEFEATURE_RECT_TOP;
extern NSString * const kFACEFEATURE_RECT_BOTTOM;
extern NSString * const kFACEFEATURE_RECT_LEFT;
extern NSString * const kFACEFEATURE_RECT_RIGHT;

#define FACEFEATURE_PIXELSIZE (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))

@interface DCFaceFeatureHelper : NSObject {
}

DEFINE_SINGLETON_FOR_HEADER(DCFaceFeatureHelper);

- (NSDictionary *)detectFaceFeaturesForDataItem:(NSString *)dataItemUID;

@end
