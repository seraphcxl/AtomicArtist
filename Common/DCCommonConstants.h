//
//  DCCommonConstants.h
//  DCLog
//
//  Created by Chen XiaoLiang on 12-12-19.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#ifndef DCLog_DCCommonConstants_h
#define DCLog_DCCommonConstants_h

/******************************************************************************/

#if !defined(__clang__) || __clang_major__ < 3
#ifndef __bridge
#define __bridge
#endif

#ifndef __bridge_retain
#define __bridge_retain
#endif

#ifndef __bridge_retained
#define __bridge_retained
#endif

#ifndef __autoreleasing
#define __autoreleasing
#endif

#ifndef __strong
#define __strong
#endif

#ifndef __unsafe_unretained
#define __unsafe_unretained
#endif

#ifndef __weak
#define __weak
#endif
#endif

/******************************************************************************/

#ifndef SAFE_ARC_DEFINES
#define SAFE_ARC_DEFINES

#if __has_feature(objc_arc)
#define SAFE_ARC_PROP_STRONG strong
#define SAFE_ARC_RETAIN(x)
#define SAFE_ARC_RELEASE(x)
#define SAFE_ARC_SAFERELEASE(x)
#define SAFE_ARC_AUTORELEASE(x)
#define SAFE_ARC_BLOCK_COPY(x)
#define SAFE_ARC_BLOCK_RELEASE(x)
#define SAFE_ARC_SUPER_DEALLOC()
#define SAFE_ARC_AUTORELEASE_POOL_START() @autoreleasepool {
#define SAFE_ARC_AUTORELEASE_POOL_END() }
#else
#define SAFE_ARC_PROP_STRONG retain
#define SAFE_ARC_RETAIN(x) ([(x) retain])
#define SAFE_ARC_RELEASE(x) ([(x) release])
#define SAFE_ARC_SAFERELEASE(x) ({[(x) release]; (x) = nil;})
#define SAFE_ARC_AUTORELEASE(x) ([(x) autorelease])
#define SAFE_ARC_BLOCK_COPY(x) (Block_copy(x))
#define SAFE_ARC_BLOCK_RELEASE(x) (Block_release(x))
#define SAFE_ARC_SUPER_DEALLOC() ([super dealloc])
#define SAFE_ARC_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#define SAFE_ARC_AUTORELEASE_POOL_END() [pool drain];
#endif

#if __has_feature(objc_arc_weak)
#define SAFE_ARC_PROP_WEAK weak
#define __SAFE_ARC_PROP_WEAK __weak
#elif __has_feature(objc_arc)
#define SAFE_ARC_PROP_WEAK unsafe_unretained
#define __SAFE_ARC_PROP_WEAK __unsafe_unretained
#else
#define SAFE_ARC_PROP_WEAK assign
#define __SAFE_ARC_PROP_WEAK __unsafe_unretained
#endif

#endif

/******************************************************************************/

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

#endif
