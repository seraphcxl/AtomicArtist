//
//  SafeARC.h
//  
//
//  Created by Chen XiaoLiang on 12-12-29.
//
//

#ifndef _SafeARC_h
#define _SafeARC_h

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

#endif
