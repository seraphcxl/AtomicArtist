//
//  DCCommonUtility.m
//  
//
//  Created by Chen XiaoLiang on 13-1-31.
//
//

#import "DCCommonUtility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation DCCommonUtility

#pragma mark - DCCommonUtility - MD5
+ (NSString *)md5:(NSData *)data {
    NSString *result = nil;
    do {
        if (!data) {
            break;
        }
        unsigned char tmp[CC_MD5_DIGEST_LENGTH] = {0};
        CC_MD5(data.bytes, data.length, tmp);
        result = [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5], tmp[6], tmp[7], tmp[8], tmp[9], tmp[10], tmp[11], tmp[12], tmp[13], tmp[14], tmp[15]] lowercaseString];
    } while (NO);
    return result;
}

@end
