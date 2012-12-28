//
//  DCSingletonTemplate.h
//  
//
//  Created by Chen XiaoLiang on 12-12-28.
//
//

#ifndef _DCSingletonTemplate_h
#define _DCSingletonTemplate_h

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 && !defined (DC_DONT_USE_ARC_WEAK_FEATURE)

#define DC_SINGLETON_SAFERELEASE(className)

#else

#define DC_SINGLETON_SAFERELEASE(className) {[shared##className release]; shared##className = nil;}

#endif

#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className; \
+ (void)staticRelease; \

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
static className *shared##className = nil; \
\
+ (className *)shared##className { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
} \
\
+ (void)staticRelease { \
DC_SINGLETON_SAFERELEASE(className); \
}

#endif
