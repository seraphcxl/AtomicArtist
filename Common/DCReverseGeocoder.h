//
//  DCReverseGeocoder.h
//
//
//  Created by Chen XiaoLiang on 13-3-11.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

extern NSString * const NOTIFY_REVERSEGEO_DONE;

extern NSString * const kREVERSEGEO_LOCATION;
extern NSString * const kREVERSEGEO_LOCALITY;

@interface DCReverseGeocoder : NSObject

// Do not use this method in main thread.
- (NSString *)syncReverseGeocodeWithLatitude:(CLLocation *)location;

- (void)asyncReverseGeocodeWithLatitude:(CLLocation *)location;

@end
