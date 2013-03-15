//
//  DCMediaPocketDataItem.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-1-28.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCMediaPocketDataItem.h"

@interface DCMediaPocketDataItem () {
    NSUInteger _useCount;
    NSURL *_URL;
    NSString *_UID;
    NSString *_md5;
}

@property (nonatomic, retain) id<DCDataItem> dataItem;

@end

@implementation DCMediaPocketDataItem

@synthesize actionDelegate = _actionDelegate;
@synthesize dataItem =_dataItem;

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(self) {
            _useCount = 0;
        }
    }
    return self;
}

- (id)initWithDataItem:(id<DCDataItem>)dataItem andUseCount:(NSUInteger)useCount{
    id result = nil;
    do {
        if (!dataItem || ![dataItem uniqueID]) {
            break;
        }
        self = [self init];
        if (self) {
            self.dataItem = dataItem;
            _useCount = useCount;
            _URL = [[dataItem valueForProperty:kDATAITEMPROPERTY_URL withOptions:nil] copy];
            _UID = [[dataItem uniqueID] copy];
//            _md5 = [[dataItem md5] copy];
        }
        result = self;
    } while (NO);
    return result;
}

- (void)setActionDelegate:(id<DCDataItemActionDelegate>)actionDelegate {
    do {
        _actionDelegate = actionDelegate;
        [self.dataItem setActionDelegate:actionDelegate];
    } while (NO);
}

- (void)dealloc {
    do {
        self.actionDelegate = nil;
        
        SAFE_ARC_SAFERELEASE(_md5);
        SAFE_ARC_SAFERELEASE(_URL);
        SAFE_ARC_SAFERELEASE(_UID);
        
        self.dataItem = nil;
        
        @synchronized(self) {
            _useCount = 0;
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (DataSourceType)type {
    return [self.dataItem type];
}

- (NSURL *)URL {
    SAFE_ARC_RETAIN(_URL);
    SAFE_ARC_AUTORELEASE(_URL);
    return _URL;
}

- (NSString *)uniqueID {
    SAFE_ARC_RETAIN(_UID);
    SAFE_ARC_AUTORELEASE(_UID);
    return _UID;
}

- (id)origin {
    return [self.dataItem origin];
}

- (NSString *)md5 {
    SAFE_ARC_RETAIN(_md5);
    SAFE_ARC_AUTORELEASE(_md5);
    return _md5;
}

- (id)valueForProperty:(NSString *)property withOptions:(NSDictionary *)options {
    return [self.dataItem valueForProperty:property withOptions:options];
}

- (void)save:(NSString *)filePath {
    [self.dataItem save:filePath];
}

- (NSUInteger)increaseUseCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            ++_useCount;
            result = _useCount;
        }
    } while (NO);
    return result;
}

- (NSUInteger)decreaseUseCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            if (_useCount > 0) {
                --_useCount;
            }
            result = _useCount;
        }
    } while (NO);
    return result;
}

- (NSUInteger)useCount {
    NSUInteger result = 0;
    do {
        @synchronized(self) {
            result = _useCount;
        }
    } while (NO);
    return result;
}

- (void)zeroUseCount {
    do {
        @synchronized(self) {
            _useCount = 0;
        }
    } while (NO);
}

@end
