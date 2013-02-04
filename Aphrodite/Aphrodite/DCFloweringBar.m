//
//  DCFloweringBar.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCFloweringBar.h"
#import "DCBudButton.h"
#import "DCPetalView.h"
#import "DCDewButton.h"

@interface DCFloweringBar () {
    NSMutableDictionary *_petals;  // key:(NSString *) value:(DCPetalView *)
}

- (void)petalWithered;
- (DCPetalView *)createPetal:(CGFloat)angle;

@end

@implementation DCFloweringBar

@synthesize anchor = _anchor;
@synthesize floweringBranchView = _floweringBranchView;
@synthesize budButton = _budButton;

- (id)initWithAnchor:(CGPoint)aAnchor andFloweringBranch:(UIView *)aFloweringBranchView {
    @synchronized(self) {
        NSAssert(aFloweringBranchView, @"aFloweringBranchView == nil");
        self = [super init];
        if (self) {
            _anchor = aAnchor;
            _floweringBranchView = aFloweringBranchView;
            
            [self petalWithered];
            _petals = [NSMutableDictionary dictionary];
            SAFE_ARC_RETAIN(_petals);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            [self petalWithered];
            
            if (self.budButton) {
                [self.budButton removeFromSuperview];
                SAFE_ARC_SAFERELEASE(_budView);
            }
            
            _floweringBranchView = nil;
            _anchor = CGPointZero;
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

#pragma mark - DCFloweringBar - Petal
- (DCPetalView *)getPetal:(CGFloat)angle {
    DCPetalView *result = nil;
    do {
        if (!_petals || [_petals count] == 0) {
            break;
        }
        @synchronized(self) {
            result = [_petals objectForKey:[DCPetalView uniqueIDForAngle:angle]];
        }
    } while (NO);
    return result;
}

- (void)petalWithered {
    do {
        @synchronized(self) {
            if (_petals) {
                for (DCPetalView *petal in _petals) {
                    [petal removeFromSuperview];
                }
                
                [_petals removeAllObjects];
                SAFE_ARC_SAFERELEASE(_petals);
            }
        }
    } while (NO);
}

- (DCPetalView *)createPetal:(CGFloat)angle {
    DCPetalView *result = nil;
    do {
        result = [[DCPetalView alloc] init];
        SAFE_ARC_AUTORELEASE(result);
        [_petals setObject:result forKey:[DCPetalView uniqueIDForAngle:angle]];
    } while (NO);
    return result;
}

#pragma mark - DCFloweringBar - Dew
- (DCDewButton *)getDew:(CGFloat)radius onPetal:(CGFloat)angle {
    DCDewButton *result = nil;
    do {
        if (!_petals || [_petals count] == 0) {
            break;
        }
        @synchronized(self) {
            DCPetalView *petal = [self getPetal:angle];
            if (petal) {
                result = [petal getDew:radius];
            }
        }
    } while (NO);
    return result;
}

- (void)addDew:(DCDewButton *)aDewButton atPetal:(DCPetalView *)aPetalView {
    do {
        if (!aDewButton || !aPetalView) {
            break;
        }
        @synchronized(self) {
            DCPetalView *petalView = [self getPetal:aPetalView.angle];
            if (!petalView) {
                petalView = [self createPetal:aPetalView.angle];
            }
            NSAssert(petalView, @"petalView == nil");
            [petalView addDew:aDewButton];
        }
    } while (NO);
}

- (void)addDew:(DCDewButton *)aDewButton atAngle:(CGFloat)angle {
    do {
        if (!aDewButton) {
            break;
        }
        @synchronized(self) {
            DCPetalView *petalView = [self getPetal:angle];
            if (!petalView) {
                petalView = [self createPetal:angle];
            }
            NSAssert(petalView, @"petalView == nil");
            [petalView addDew:aDewButton];
        }
    } while (NO);
}
@end
