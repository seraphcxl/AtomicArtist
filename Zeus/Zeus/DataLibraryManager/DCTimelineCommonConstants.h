//
//  DCTimelineCommonConstants.h
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-6.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZeroCFGregorianUnits(gregorianUnit) { gregorianUnit.years = 0; gregorianUnit.months = 0; gregorianUnit.days = 0; gregorianUnit.hours = 0; gregorianUnit.minutes = 0; gregorianUnit.seconds = 0.0f; }

#define CFGregorianUnits_1Month {0, 1, 0, 0, 0, 0.0f}
#define CFGregorianUnits_7Days {0, 0, 7, 0, 0, 0.0f}
#define CFGregorianUnits_3Days {0, 0, 3, 0, 0, 0.0f}
#define CFGregorianUnits_1Day {0, 0, 1, 0, 0, 0.0f}
#define CFGregorianUnits_8Hours {0, 0, 0, 8, 0, 0.0f}

static CFGregorianUnits CFGregorianUnits_IntervalArray[] = {CFGregorianUnits_1Month, CFGregorianUnits_7Days, CFGregorianUnits_3Days, CFGregorianUnits_1Day, CFGregorianUnits_8Hours};

typedef enum {
    GUIF_1Month = 0,
    GUIF_7Days,
    GUIF_3Days,
    GUIF_1Day,
    GUIF_8Hours,
    
    GUIF_Count,
    GUIF_Unknown = 0xffffffff,
} GregorianUnitIntervalFineness;

#define DCTimeline_Group_CountForRefine (24)
#define DCTimeline_Group_NotifyhFrequencyForAddItem (16)

extern int GregorianUnitCompare(CFGregorianUnits left, CFGregorianUnits right);

@interface DCTimelineCommonConstants : NSObject

@end
