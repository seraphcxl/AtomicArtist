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

@interface DCReverseGeocoder : NSObject

- (NSString *)reverseGeocodeWithLatitude:(CLLocation *)location;

@end
