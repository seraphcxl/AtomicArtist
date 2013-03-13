//
//  DCTimelineCommonConstants.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-6.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCTimelineCommonConstants.h"

double accurateDistanceMeters(double lat1, double lng1, double lat2, double lng2) {
    double result = 0.0f;
    do {
        double dlat = sin(0.5 * (lat2 - lat1));
        double dlng = sin(0.5 * (lng2 - lng1));
        double x = dlat * dlat + dlng * dlng * cos(lat1) * cos(lat2);
        result = (2 * atan2(sqrt(x), sqrt(MAX(0.0, 1.0 - x)))) * EARTH_RADIUS_METERS;
    } while (NO);
    return result;
}

double fastDistanceMeters(double lat1, double lng1, double lat2, double lng2) {
    double result = 0.0f;
    do {
        if (ABS(lat1 - lat2) > RAD_PER_DEG || ABS(lng1 - lng2) > RAD_PER_DEG) {
            result = accurateDistanceMeters(lat1, lng1, lat2, lng2);
        } else {
            double sineLat = (lat1 - lat2);
            double sineLng = (lng1 - lng2);
            double cosTerms = cos((lat1 + lat2) / 2.0);
            cosTerms *= cosTerms;
            double trigTerm = sineLat * sineLat + cosTerms * sineLng * sineLng;
            trigTerm = sqrt(trigTerm);
            result = trigTerm * EARTH_RADIUS_METERS;
        }
    } while (NO);
    return result;
}

NSComparisonResult GregorianUnitCompare(CFGregorianUnits left, CFGregorianUnits right) {
    int result = NSOrderedSame;
    do {
        left.years = ABS(left.years);
        left.months = ABS(left.months);
        left.days = ABS(left.days);
        left.hours = ABS(left.hours);
        left.minutes = ABS(left.minutes);
        left.seconds = ABS(left.seconds);
        
        right.years = ABS(right.years);
        right.months = ABS(right.months);
        right.days = ABS(right.days);
        right.hours = ABS(right.hours);
        right.minutes = ABS(right.minutes);
        right.seconds = ABS(right.seconds);
        
        // Year
        if (left.years > right.years) {
            result = NSOrderedDescending;
        } else if (left.years < right.years) {
            result = NSOrderedAscending;
        } else {
            // Month
            if (left.months > right.months) {
                result = NSOrderedDescending;
            } else if (left.months < right.months) {
                result = NSOrderedAscending;
            } else {
                // Day
                if (left.days > right.days) {
                    result = NSOrderedDescending;
                } else if (left.days < right.days) {
                    result = NSOrderedAscending;
                } else {
                    // Hour
                    if (left.hours > right.hours) {
                        result = NSOrderedDescending;
                    } else if (left.hours < right.hours) {
                        result = NSOrderedAscending;
                    } else {
                        // Minute
                        if (left.minutes > right.minutes) {
                            result = NSOrderedDescending;
                        } else if (left.minutes < right.minutes) {
                            result = NSOrderedAscending;
                        } else {
                            // Second
                            if (left.seconds > right.seconds) {
                                result = NSOrderedDescending;
                            } else if (left.seconds < right.seconds) {
                                result = NSOrderedAscending;
                            } else {
                                result = NSOrderedSame;
                            }
                        }
                    }
                }
            }
        }
    } while (NO);
    return result;
}

@implementation DCTimelineCommonConstants

@end
