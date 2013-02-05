//
//  DCTimelineALAssetsLibrary.m
//  Zeus
//
//  Created by Chen XiaoLiang on 13-2-5.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTimelineALAssetsLibrary.h"
#import "DCCommonUtility.h"

@interface DCTimelineALAssetsLibrary () {
    ALAssetsGroup *_assetsTimelineGroup;
}

- (void)initAssetsTimelineGroup;
- (void)clearTimelineGroupCache;

@end

@implementation DCTimelineALAssetsLibrary

@synthesize refinedGregorianUnit = _refinedGregorianUnit;

#pragma mark - DCTimelineALAssetsLibrary - DCDataLibraryBase
- (BOOL)connect:(NSDictionary *)params {
    BOOL result = NO;
    do {
        @synchronized(self) {
            result = [super connect:params];
            NSAssert(result, @"[super connect:params] error.");
            ZeroCFGregorianUnits(_refinedGregorianUnit);
        }
        result = YES;
    } while (NO);
    return result;
}

- (BOOL)disconnect {
    BOOL result = NO;
    do {
        @synchronized(self) {
            ZeroCFGregorianUnits(_refinedGregorianUnit);
            
            result = [super disconnect];
            NSAssert(result, @"[super disconnect] error.");
        }
        
        result = YES;
    } while (NO);
    return result;
}

- (void)clearCache {
    do {
        @synchronized(self) {
            [super clearCache];
            
            SAFE_ARC_SAFERELEASE(_assetsTimelineGroup);
        }
    } while (NO);
}

#pragma mark - DCTimelineALAssetsLibrary - DCTimelineDataLibrary
- (void)enumTimelineNotifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    ;
                } else {
                    ;
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
                [self initAssetsTimelineGroup];
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
            if (frequency == 0) {
                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                [_assetsTimelineGroup enumerateAssetsUsingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (void)enumTimelineAtIndexes:(NSIndexSet *)indexSet notifyWithFrequency:(NSUInteger)frequency {
    SAFE_ARC_AUTORELEASE_POOL_START()
    do {
        void (^enumerator)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            do {
                if (_cancelEnum) {
                    *stop = YES;
                    _enumerating = NO;
                    break;
                }
                
                if (result != nil) {
                    ;
                } else {
                    ;
                }
            } while (NO);
        };
        
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
                [self initAssetsTimelineGroup];
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
            if (frequency == 0) {
                [NSException raise:@"DCTimelineALAssetsLibrary Error" format:@"Reason: _frequency == 0"];
                break;
            }
            
            if (!_enumerating) {
                [self clearCache];
                
                _frequency = frequency;
                _enumCount = 0;
                _cancelEnum = NO;
                _enumerating = YES;
                [_assetsTimelineGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:enumerator];
            }
        }
    } while (NO);
    SAFE_ARC_AUTORELEASE_POOL_END()
}

#pragma mark - DCTimelineALAssetsLibrary - Private
- (void)initAssetsTimelineGroup {
    do {
        @synchronized(self) {
            if (!_assetsTimelineGroup) {
                ALAssetsLibrary *assetsLibrary = [DCAssetsLibAgent sharedDCAssetsLibAgent].assetsLibrary;
                if (!assetsLibrary) {
                    [NSException raise:@"DCALAssetsLibrary Error" format:@"Reason: _assetsLibrary == nil"];
                    break;
                }
                
                NSConditionLock *_lock = [[NSConditionLock alloc] initWithCondition:0];
                SAFE_ARC_AUTORELEASE(_lock);
                
                SAFE_ARC_AUTORELEASE_POOL_START()
                void (^enumerator)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
                    do {
                        if (_cancelEnum) {
                            *stop = _cancelEnum;
                            _enumerating = NO;
                            break;
                        }
                        
                        if (group != nil && [group numberOfAssets] > 0) {
                            NSAssert(!_assetsTimelineGroup, @"_assetsTimelineGroup != nil");
                            @synchronized(self) {
                                if (_cancelEnum) {
                                    *stop = _cancelEnum;
                                    _enumerating = NO;
                                    break;
                                }
                                _assetsTimelineGroup = group;
                                SAFE_ARC_RETAIN(_assetsTimelineGroup);
                            }
                            dc_debug_NSLog(@"Add timeline group count = %d", [group numberOfAssets]);
                        } else {
                            ;
                        }
                    } while (NO);
                    
                    if ([_lock tryLockWhenCondition:0]) {
                        [_lock unlockWithCondition:1];
                    }
                };
                
                void (^failureReporter)(NSError *error) = ^(NSError *error) {
                    if ([_lock tryLockWhenCondition:0]) {
                        [_lock unlockWithCondition:1];
                    }
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enum ALAssetsGroup failed" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    SAFE_ARC_AUTORELEASE(alertView);
                    [alertView show];
                };
                
                if (!_enumerating) {
                    [self clearTimelineGroupCache];
                    
                    _cancelEnum = NO;
                    _enumerating = YES;
                    NSAssert(assetsLibrary, @"_assetsLibrary == nil");
                    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:enumerator failureBlock:failureReporter];
                    [_lock lockWhenCondition:1];
                    [_lock unlockWithCondition:0];
                }
                SAFE_ARC_AUTORELEASE_POOL_END()
            }
            NSAssert(_assetsTimelineGroup, @"_assetsTimelineGroup == nil");
        }
    } while (NO);
}

- (void)clearTimelineGroupCache {
    do {
        @synchronized(self) {
            _cancelEnum = YES;
            
            SAFE_ARC_SAFERELEASE(_assetsTimelineGroup);
        }
    } while (NO);
}

@end
