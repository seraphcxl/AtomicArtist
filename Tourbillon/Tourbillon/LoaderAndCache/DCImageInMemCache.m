//
//  DCImageInMemCache.m
//  Tourbillon
//
//  Created by Chen XiaoLiang on 12-12-27.
//  Copyright (c) 2012年 Chen XiaoLiang. All rights reserved.
//

#import "DCImageInMemCache.h"

@interface DCImageInMemCache () {
    NSMutableArray *_stack;  // key:(NSString *)
    NSMutableDictionary *_cache;  // key:(NSString *) valve:(UIImage *)
    long _countMax;
}

- (void)deallocCache;

@end

@implementation DCImageInMemCache

DEFINE_SINGLETON_FOR_CLASS(DCImageInMemCache);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            [self resetCache];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        [self deallocCache];
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)resetCache {
    do {        
        [self deallocCache];
        @synchronized (self) {
            _countMax = IMAGEINMEMCACHE_MAXCOUNT;
            
            _stack = [[NSMutableArray alloc] initWithCapacity:_countMax];
            
            _cache = [[NSMutableDictionary alloc] initWithCapacity:_countMax];
        }
    } while (NO);
}

- (UIImage *)imageFoeKey:(NSString *)key {
    UIImage *result = nil;
    do {
        if (!key || !_cache || !_stack) {
            break;
        }
        @synchronized (self) {
            result = (UIImage *)[_cache objectForKey:key];
            
            if (result) {
                [_stack removeObject:key];
                [_stack insertObject:key atIndex:0];
            }
        }
    } while (NO);
    return result;
}

- (BOOL)cacheImage:(UIImage *)image ForKey:(NSString *)key {
    BOOL result = NO;
    do {
        if (!image || !key || !_cache || !_stack) {
            break;
        }
        @synchronized (self) {
            if ([_stack count] == _countMax) {
                NSString *keyForRemove = [[_stack lastObject] copy];
                SAFE_ARC_AUTORELEASE(keyForRemove);
                [_stack removeLastObject];
                [_cache removeObjectForKey:keyForRemove];
            }
            
            [_stack insertObject:key atIndex:0];
            [_cache setObject:image forKey:key];
        }
    } while (NO);
    return result;
}


- (void)deallocCache {
    do {
        @synchronized (self) {
            if (_stack) {
                [_stack removeAllObjects];
                SAFE_ARC_SAFERELEASE(_stack);
                _stack = nil;
            }
            
            if (_cache) {
                [_cache removeAllObjects];
                SAFE_ARC_SAFERELEASE(_cache);
                _cache = nil;
            }
        }
    } while (NO);
}

@end
