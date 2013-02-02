//
//  DCFloweringBar.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCFloweringBar.h"
#import "DCBudView.h"
#import "DCPetalView.h"
#import "DCDewView.h"

@interface DCFloweringBar () {
    NSMutableDictionary *_petals;  // key:(NSString *) value:(DCPetalView *)
}

- (void)petalWithered;
- (DCPetalView *)createPetal:(CGFloat)angle;

@end

@implementation DCFloweringBar

@synthesize anchor = _anchor;
@synthesize floweringBranchView = _floweringBranchView;
@synthesize budView = _budView;

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
            
            if (self.budView) {
                [self.budView removeFromSuperview];
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
            NSString *uid = [NSString stringWithFormat:@"%f", angle];
            result = [_petals objectForKey:uid];
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
        ;
    } while (NO);
    return result;
}

#pragma mark - DCFloweringBar - Dew
- (DCDewView *)getDew:(CGFloat)radius onPetal:(CGFloat)angle {
    DCDewView *result = nil;
    do {
        if (!_petals || [_petals count] == 0) {
            break;
        }
        @synchronized(self) {
            DCPetalView *petal = [self getPetalView:angle];
            if (petal) {
                result = [petal getDewView:radius];
            }
        }
    } while (NO);
    return result;
}

- (void)addDew:(DCDewView *)aDewView atPetal:(DCPetalView *)aPetalView {
    do {
        if (!aDewView || !aPetalView) {
            break;
        }
        @synchronized(self) {
        }
    } while (NO);
}

- (void)addDew:(DCDewView *)aDewView atAngle:(CGFloat)angle {
    do {
        if (!aDewView) {
            break;
        }
        @synchronized(self) {
            DCPetalView *petalView = [self getPetal:angle];
            if (!petalView) {
                petalView = [self addPetal:angle];
            }
            NSAssert(petalView, @"petalView == nil");
        }
    } while (NO);
}
@end
