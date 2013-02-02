//
//  DCPetalView.m
//  Aphrodite
//
//  Created by Chen XiaoLiang on 13-1-30.
//  Copyright (c) 2013年 Chen XiaoLiang. All rights reserved.
//

#import "DCPetalView.h"
#import "DCDewView.h"

@interface DCPetalView () {
    NSMutableDictionary *_dews;  // key:(NSString *) value:(DCDewdropView *)
}

- (void)dewDrop;

@end

@implementation DCPetalView

@synthesize angle = _angle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self dewDrop];
        _dews = [NSMutableDictionary dictionary];
        SAFE_ARC_RETAIN(_dews);
        
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            [self dewDrop];
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (NSString *)uniqueID {
    return [NSString stringWithFormat:@"%f", self.angle];
}

- (void)layoutSubviews {
    do {
        ;
    } while (NO);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - DCFloweringBar - Dew
- (DCDewView *)getDew:(CGFloat)radius {
    DCDewView *result = nil;
    do {
        if (!_dews || [_dews count] == 0) {
            break;
        }
        @synchronized(self) {
            NSString *uid = [NSString stringWithFormat:@"%f", radius];
            result = [_dews objectForKey:uid];
        }
    } while (NO);
    return result;
}

- (void)dewDrop {
    do {
        @synchronized(self) {
            if (_dews) {
                for (DCDewView *dew in _dews) {
                    [dew removeFromSuperview];
                }
                
                [_dews removeAllObjects];
                SAFE_ARC_SAFERELEASE(_dews);
            }
        }
    } while (NO);
}

- (void)addDew:(DCDewView *)aDewView {
    do {
        if (!aDewView) {
            break;
        }
        @synchronized(self) {
            DCDewView *tmpDewView = [self getDew:aDewView.radius];
            NSAssert(!tmpDewView, @"DewView at radius:%f was exsited", aDewView.radius);
            [_dews setObject:aDewView forKey:[aDewView uniqueID]];
            
            [self addSubview:aDewView];
        }
    } while (NO);
}

@end
