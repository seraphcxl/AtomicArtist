//
//  DCALAssetsLibraryHelper.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCALAssetsLibraryHelper.h"
#import "DCALAssetsLibrary.h"
#include "DCALAssetsGroup.h"

static DCALAssetsLibraryHelper *staticALAssetsLibraryHelper = nil;

@interface DCALAssetsLibraryHelper () {
    DCALAssetsLibrary *_alAssetsLibrary;
    BOOL _available;
}

@end

@implementation DCALAssetsLibraryHelper

+ (id)defaultDataLibraryHelper {
    if (!staticALAssetsLibraryHelper) {
        staticALAssetsLibraryHelper = [[super allocWithZone:nil] init];
    }
    
    return staticALAssetsLibraryHelper;
}

+ (void)staticRelease {
    if (!staticALAssetsLibraryHelper) {
        [staticALAssetsLibraryHelper release];
        staticALAssetsLibraryHelper = nil;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultDataLibraryHelper];
}

- (BOOL)connect:(NSDictionary *)params {
    if (!_alAssetsLibrary) {
        _alAssetsLibrary = [[DCALAssetsLibrary alloc] init];
    }
    _available = [_alAssetsLibrary connect:params];
    return _available;
}

- (BOOL)disconnect {
    if (_alAssetsLibrary) {
        _available = ![_alAssetsLibrary disconnect];
        [_alAssetsLibrary release];
        _alAssetsLibrary = nil;
    }
    return !_available;
}

- (BOOL)available {
    return _available;
}

- (void)clearCache {
    if (_alAssetsLibrary) {
        [_alAssetsLibrary clearCache];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
    }
}

- (void)enumGroups:(id)param notifyWithFrequency:(NSUInteger)frequency {
    if (_alAssetsLibrary) {
        [_alAssetsLibrary enumGroups:param notifyWithFrequency:frequency];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
    }
}

- (NSUInteger)groupsCount {
    if (_alAssetsLibrary) {
        return [_alAssetsLibrary groupsCount];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return 0;
    }
}

- (id <DCDataGroup>)groupWithUID:(NSString *)uid {
    if (_alAssetsLibrary) {
        return [_alAssetsLibrary groupWithUID:uid];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return nil;
    }
}

- (NSString *)groupUIDAtIndex:(NSUInteger)index {
    if (_alAssetsLibrary) {
        return [_alAssetsLibrary groupUIDAtIndex:index];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return nil;
    }
}

- (NSInteger)indexForGroupUID:(NSString *)groupUID {
    if (_alAssetsLibrary) {
        return [_alAssetsLibrary indexForGroupUID:groupUID];
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return 0;
    }
}

- (void)clearCacheInGroup:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            [group clearCache];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
    }
}

- (void)enumItems:(id)param inGroup:(NSString *)groupUID notifyWithFrequency:(NSUInteger)frequency {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            [group enumItems:param notifyWithFrequency:frequency];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
    }
}

- (void)enumItemAtIndexes:(NSIndexSet *)indexSet withParam:(id)param inGroup:(NSString *)groupUID notifyWithFrequency:(NSUInteger)frequency {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            [group enumItemAtIndexes:indexSet withParam:param notifyWithFrequency:frequency];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
    }
}

- (NSUInteger)itemsCountInGroup:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            return [group itemsCount];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
            return 0;
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return 0;
    }
}

- (id <DCDataItem>)itemWithUID:(NSString *)uid inGroup:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            return [group itemWithUID:uid];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
            return nil;
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return nil;
    }
}

- (NSString *)itemUIDAtIndex:(NSUInteger)index inGroup:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            return [group itemUIDAtIndex:index];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
            return nil;
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return nil;
    }
}

- (NSInteger)indexForItemUID:(NSString *)itemUID inGroup:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            return [group indexForItemUID:itemUID];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
            return 0;
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return 0;
    }
}

- (BOOL)isGroupEnumerated:(NSString *) groupUID {
    if (_alAssetsLibrary) {
        id <DCDataGroup> group = [_alAssetsLibrary groupWithUID:groupUID];
        if (group) {
            return [group isEnumerated];
        } else {
            [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: can not find group id == %@", groupUID];
            return NO;
        }
    } else {
        [NSException raise:@"DCALAssetsLibraryHelper error" format:@"Reason: _alAssetsLibrary == nil"];
        return NO;
    }
}

- (UIImage *)defaultPosterImage {
    return nil;
}

- (UIImage *)defaultThumbnail {
    return nil;
}

@end
