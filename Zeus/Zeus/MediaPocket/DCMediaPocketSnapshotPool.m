//
//  DCMediaPocketSnapshotPool.m
//  Whip
//
//  Created by Chen XiaoLiang on 13-2-19.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCMediaPocketSnapshotPool.h"

@interface DCMediaPocketSnapshotPool () {
    NSMutableDictionary *_dict;  // key:(NSString *) value:(DCMediaPocket *)
}

@end

@implementation DCMediaPocketSnapshotPool

DEFINE_SINGLETON_FOR_CLASS(DCMediaPocketSnapshotPool);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _dict = [NSMutableDictionary dictionary];
            SAFE_ARC_RETAIN(_dict);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (_dict) {
                [_dict removeAllObjects];
                SAFE_ARC_SAFERELEASE(_dict);
            }
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (NSArray *)allKeysForSnapshots {
    NSArray *result = nil;
    do {
        @synchronized(self) {
            if (!_dict) {
                break;
            }
            result = [_dict allKeys];
        }
    } while (NO);
    return result;
}

- (DCMediaPocket *)mediaPocket:(NSString *)uniqueID {
    DCMediaPocket *result = nil;
    do {
        @synchronized(self) {
            if (!_dict || !uniqueID) {
                break;
            }
            result = [_dict objectForKey:uniqueID];
            SAFE_ARC_RETAIN(result);
            SAFE_ARC_AUTORELEASE(result);
        }
    } while (NO);
    return result;
}

- (void)insertSnapshot:(DCMediaPocket *)mediaPocket {
    do {
        @synchronized(self) {
            if (!_dict || !mediaPocket) {
                break;
            }
            [_dict setObject:mediaPocket forKey:[mediaPocket uniqueID]];
        }
    } while (NO);
}

- (void)removeSnapshot:(NSString *)uniqueID {
    do {
        @synchronized(self) {
            if (!_dict || !uniqueID) {
                break;
            }
            [_dict removeObjectForKey:uniqueID];
        }
    } while (NO);
}

@end
