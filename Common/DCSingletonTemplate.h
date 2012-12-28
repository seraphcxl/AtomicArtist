//
//  DCSingletonTemplate.h
//
//
//  Created by Chen XiaoLiang on 12-12-28.
//
//

#ifndef _DCSingletonTemplate_h
#define _DCSingletonTemplate_h

#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className; \
+ (void)staticRelease; \

#endif


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 && !defined (DC_DONT_USE_ARC_WEAK_FEATURE)

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
+ (void)staticRelease {}

#else

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
static className *shared##className = nil; \
\
+ (className *)shared##className { \
@synchronized(self) { \
if (shared##className == nil) { \
[[self alloc] init]; \
} \
} \
return shared##className; \
} \
\
+ (void)staticRelease { \
@synchronized(self) { \
if (shared##className) { \
[shared##className dealloc]; \
shared##className = nil; \
} \
} \
} \
\
+ (id)allocWithZone:(NSZone *)zone { \
@synchronized(self) { \
if (shared##className == nil) { \
shared##className = [super allocWithZone:zone]; \
return shared##className; \
} \
} \
return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone { return self; } \
\
- (id)retain { return self; } \
\
- (unsigned)retainCount { return UINT_MAX; } \
\
- (oneway void)release {} \
\
- (id)autorelease { return self; }

#endif