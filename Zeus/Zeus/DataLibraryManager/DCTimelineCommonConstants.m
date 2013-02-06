//
//  DCTimelineCommonConstants.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-6.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCTimelineCommonConstants.h"

int GregorianUnitCompare(CFGregorianUnits left, CFGregorianUnits right) {
    int result = 0;
    do {
        // Year
        if (left.years > right.years) {
            result = 1;
        } else if (left.years < right.years) {
            result = -1;
        } else {
            // Month
            if (left.months > right.months) {
                result = 1;
            } else if (left.months < right.months) {
                result = -1;
            } else {
                // Day
                if (left.days > right.days) {
                    result = 1;
                } else if (left.days < right.days) {
                    result = -1;
                } else {
                    // Hour
                    if (left.hours > right.hours) {
                        result = 1;
                    } else if (left.hours < right.hours) {
                        result = -1;
                    } else {
                        // Minute
                        if (left.minutes > right.minutes) {
                            result = 1;
                        } else if (left.minutes < right.minutes) {
                            result = -1;
                        } else {
                            // Second
                            if (left.seconds > right.seconds) {
                                result = 1;
                            } else if (left.seconds < right.seconds) {
                                result = -1;
                            } else {
                                result = 0;
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
