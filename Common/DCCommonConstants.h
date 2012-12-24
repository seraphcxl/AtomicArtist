//
//  DCCommonConstants.h
//  DCLog
//
//  Created by Chen XiaoLiang on 12-12-19.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#ifndef DCLog_DCCommonConstants_h
#define DCLog_DCCommonConstants_h

//
// ARC on iOS 4 and 5
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 && !defined (DC_DONT_USE_ARC_WEAK_FEATURE)

#define dc_weak   weak
#define __dc_weak __weak
#define dc_nil(x)


#else

#define dc_weak   unsafe_unretained
#define __dc_weak __unsafe_unretained
#define dc_nil(x) x = nil

#endif

#endif
