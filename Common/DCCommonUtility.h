//
//  DCCommonUtility.h
//  
//
//  Created by Chen XiaoLiang on 13-1-31.
//
//

#import <Foundation/Foundation.h>

#define ZeroCFGregorianUnits(gregorianUnit) { gregorianUnit.years = 0; gregorianUnit.months = 0; gregorianUnit.days = 0; gregorianUnit.hours = 0; gregorianUnit.minutes = 0; gregorianUnit.seconds = 0.0f; }
#define CFGregorianUnits_12Hour {0, 0, 0, 12, 0, 0.0f}
#define CFGregorianUnits_6Hour {0, 0, 0, 6, 0, 0.0f}
#define CFGregorianUnits_1Hour {0, 0, 0, 1, 0, 0.0f}
#define CFGregorianUnits_30Minutes {0, 0, 0, 0, 30, 0.0f}

@interface DCCommonUtility : NSObject

#pragma mark - DCCommonUtility - MD5
+ (NSString *)md5:(NSData *)data;

@end
