//
//  DCLoaderWorkshop.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCLoaderWorkshop.h"

@interface DCLoaderWorkshop () {
    NSMutableDictionary *_dictForQueue;
}

@end

@implementation DCLoaderWorkshop

DEFINE_SINGLETON_FOR_CLASS(DCLoaderWorkshop);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            NSAssert(!_dictForQueue, @"_dictForQueue != nil");
            _dictForQueue = [NSMutableDictionary dictionary];
            SAFE_ARC_RETAIN(_dictForQueue);
            
            for (DCLoaderUID uid = (DCLoaderUID)0; uid < DCLoaderUID_Count; ++uid) {
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [queue setMaxConcurrentOperationCount:1];
                SAFE_ARC_AUTORELEASE(queue);
                [_dictForQueue setObject:queue forKey:[NSNumber numberWithUnsignedInteger:uid]];
            }
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (_dictForQueue) {
                for (DCLoaderUID uid = (DCLoaderUID)0; uid < DCLoaderUID_Count; ++uid) {
                    [self shutDownPipeline:uid];
                }
                [_dictForQueue removeAllObjects];
                SAFE_ARC_SAFERELEASE(_dictForQueue);
            }
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (NSOperationQueue *)pipeline:(DCLoaderUID)uniqueID {
    NSOperationQueue *result = nil;
    do {
        @synchronized(self) {
            NSNumber *uidNum = [NSNumber numberWithUnsignedInteger:uniqueID];
            result = [_dictForQueue objectForKey:uidNum];
        }
    } while (NO);
    return result;
}

- (void)addOperation:(NSOperation *)opt toPipeline:(DCLoaderUID)uniqueID {
    do {
        if (!opt) {
            break;
        }
        @synchronized(self) {
            NSOperationQueue *queue = [self pipeline:uniqueID];
            if (queue) {
                [queue addOperation:opt];
            }
        }
    } while (NO);
}

- (void)shutDownPipeline:(DCLoaderUID)uniqueID {
    do {
        @synchronized(self) {
            NSOperationQueue *queue = [self pipeline:uniqueID];
            if (queue) {
                [queue cancelAllOperations];
                [queue waitUntilAllOperationsAreFinished];
            }
        }
    } while (NO);
}

@end
