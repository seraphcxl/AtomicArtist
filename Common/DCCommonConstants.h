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
#define dc_release(x)
#define dc_dealloc(x)
#define dc_retain(x)
#define dc_autorelease(x)

#else

#define dc_weak   unsafe_unretained
#define __dc_weak __unsafe_unretained
#define dc_nil(x) x = nil
#define dc_release(x) {if (x) {[x release];}}
#define dc_dealloc(x) {if (x) {[x dealloc];}}
#define dc_retain(x) {if (x) {[x retain];}}
#define dc_autorelease(x) {if (x) {[x autorelease];}}

#endif

#ifdef DEBUG
#define dc_debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define dc_debug_NSLog(format, ...)
#endif

#if defined(__MACH__)

#ifdef __cplusplus
#define DC_EXTERN extern "C"
#define DC_PRIVATE_EXTERN __private_extern__
#else
#define DC_EXTERN extern
#define DC_PRIVATE_EXTERN __private_extern__
#endif

//
// For Windows
//

#elif defined(WIN32)

#ifndef _NSBUILDING_COREDATA_DLL
#define _NSWINDOWS_DLL_GOOP __declspec(dllimport)
#else
#define _NSWINDOWS_DLL_GOOP __declspec(dllexport)
#endif

#ifdef __cplusplus
#define DC_EXTERN extern "C" _NSWINDOWS_DLL_GOOP
#define DC_PRIVATE_EXTERN extern
#else
#define DC_EXTERN _NSWINDOWS_DLL_GOOP extern
#define DC_PRIVATE_EXTERN extern
#endif

//
//  For Solaris
//

#elif defined(SOLARIS)

#ifdef __cplusplus
#define DC_EXTERN extern "C"
#define DC_PRIVATE_EXTERN extern "C"
#else
#define DC_EXTERN extern
#define DC_PRIVATE_EXTERN extern
#endif

#endif


#endif
