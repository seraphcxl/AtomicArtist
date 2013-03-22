//
//  DCMediaBucket.m
//
//
//  Created by Chen XiaoLiang on 13-2-19.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCMediaBucket.h"

@interface DCMediaBucket () {
    NSMutableArray *_array;  // value:(NSString *)
}

@end

@implementation DCMediaBucket

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _array = [NSMutableArray array];
            SAFE_ARC_RETAIN(_array);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (_array) {
                [_array removeAllObjects];
                SAFE_ARC_SAFERELEASE(_array);
            }
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (NSUInteger)itemCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (!_array) {
                break;
            }
            result = [_array count];
        }
    } while (NO);
    return result;
}

- (NSString *)itemUIDAtIndex:(NSUInteger)idx {
    NSString *result = nil;
    do {
        @synchronized(self) {
            if (!_array || idx >= [_array count]) {
                break;
            }
            result = [_array objectAtIndex:idx];
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
        }
    } while (NO);
    return result;
}

- (void)insertItemUID:(NSString *)itemUID {
    do {
        @synchronized(self) {
            if (!_array) {
                break;
            }
            [_array addObject:itemUID];
        }
    } while (NO);
}

- (void)removeItemUID:(NSString *)itemUID {
    do {
        @synchronized(self) {
            if (!_array) {
                break;
            }
            [_array removeObject:itemUID];
        }
    } while (NO);
}

- (NSInteger)findItem:(NSString *)uniqueID {
    NSInteger result = -1;
    do {
        @synchronized(self) {
            if (!_array) {
                break;
            }
            NSInteger idx = 0;
            for (NSString *uid in _array) {
                if ([uid isEqualToString:uniqueID]) {
                    result = idx;
                    break;
                }
                ++idx;
            }
        }
    } while (NO);
    return result;
}

@end
