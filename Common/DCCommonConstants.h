//
//  DCCommonConstants.h
//  DCLog
//
//  Created by Chen XiaoLiang on 12-12-19.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

/******************************************************************************/

#ifndef DCLog_DCCommonConstants_h
#define DCLog_DCCommonConstants_h

#ifdef DEBUG
#define dc_debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define dc_debug_NSLog(format, ...)
#endif

/******************************************************************************/

//
// For Mac OS && iOS
// 

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

/******************************************************************************/

#ifndef DC_RGB_DEFINE
#define DC_RGB_DEFINE
#define DC_RGB(x) (x / 255.0f)
#endif

/******************************************************************************/

#endif
