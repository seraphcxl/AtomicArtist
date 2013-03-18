//
//  DCTimelineCommonConstants.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-6.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

//#define DCTimeline_Method_Refine_Enable 1

#define ZeroCFGregorianUnits(gregorianUnit) { gregorianUnit.years = 0; gregorianUnit.months = 0; gregorianUnit.days = 0; gregorianUnit.hours = 0; gregorianUnit.minutes = 0; gregorianUnit.seconds = 0.0f; }

#define CFGregorianUnits_Month(n) {0, n, 0, 0, 0, 0.0f}
#define CFGregorianUnits_Day(n) {0, 0, n, 0, 0, 0.0f}
#define CFGregorianUnits_Hour(n) {0, 0, 0, n, 0, 0.0f}

#define CFGregorianUnits_1Month CFGregorianUnits_Month(1)
#define CFGregorianUnits_7Days CFGregorianUnits_Day(7)
#define CFGregorianUnits_3Days CFGregorianUnits_Day(3)
#define CFGregorianUnits_1Day CFGregorianUnits_Day(1)
#define CFGregorianUnits_8Hours CFGregorianUnits_Hour(8)
#define CFGregorianUnits_3Hours CFGregorianUnits_Hour(3)

static CFGregorianUnits CFGregorianUnits_IntervalArray[] = {CFGregorianUnits_1Month, CFGregorianUnits_7Days, CFGregorianUnits_3Days, CFGregorianUnits_1Day, CFGregorianUnits_8Hours, CFGregorianUnits_3Hours};

typedef enum {
    GUIF_1Month = 0,
    GUIF_7Days,
    GUIF_3Days,
    GUIF_1Day,
    GUIF_8Hours,
    GUIF_3Hours,
    
    GUIF_Count,
    GUIF_Unknown = 0xffffffff,
} GregorianUnitIntervalFineness;

#define DCTimeline_Group_CountForRefine (24)
#define DCTimeline_Group_NotifyhFrequencyForAddItem (16)

#define CFGregorianUnits_DefinedHours CFGregorianUnits_Hour(6)
#define CFGregorianUnits_MAX {NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, 0.0f}

#define DCTimelineGroup_AssetsCountForTinyGroup (5)
#define DCTimelineGroup_AssetsCountForLargeGroup (50)

extern NSComparisonResult GregorianUnitCompare(CFGregorianUnits left, CFGregorianUnits right);

#define RAD_PER_DEG (M_PI / 180.0)
#define EARTH_RADIUS_METERS (6371004)
#define KILOMETERS(n) (1000 * n)
#define LAT_LNG_ERROR (361.0)

extern double accurateDistanceMeters(double lat1, double lng1, double lat2, double lng2);
extern double accurateDistanceMeters_V2(double lat1, double lng1, double lat2, double lng2);
extern double fastDistanceMeters(double lat1, double lng1, double lat2, double lng2);

@interface DCTimelineCommonConstants : NSObject

@end
