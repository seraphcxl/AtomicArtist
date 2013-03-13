//
//  DCReverseGeocoder.m
//
//
//  Created by Chen XiaoLiang on 13-3-11.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCReverseGeocoder.h"

@interface DCReverseGeocoder () {
}

@property (nonatomic, retain) CLGeocoder *geocoder;

@end

@implementation DCReverseGeocoder

@synthesize geocoder = _geocoder;

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _geocoder = [[CLGeocoder alloc] init];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            self.geocoder = nil;
        }
        [super dealloc];
    } while (NO);
}

- (NSString *)reverseGeocodeWithLatitude:(CLLocation *)location {
    __block NSString *result = nil;
    do {
        if (!self.geocoder) {
            break;
        }
        
        NSConditionLock *_lock = [[NSConditionLock alloc] initWithCondition:0];
        SAFE_ARC_AUTORELEASE(_lock);
        
        void (^DCGeocodeCompletionHandler)(NSArray *placemark, NSError *error) = ^(NSArray *placemark, NSError *error) {
            do {
                for (CLPlacemark *placemarkObj in placemark) {
                    result = placemarkObj.locality;
                    break;
                }
                if ([_lock tryLockWhenCondition:0]) {
                    [_lock unlockWithCondition:1];
                }
            } while (NO);
        };
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:DCGeocodeCompletionHandler];
        [_lock lockWhenCondition:1];
        [_lock unlockWithCondition:0];
    } while (NO);
    return result;
}

@end
