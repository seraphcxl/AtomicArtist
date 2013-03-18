//
//  DCViewCtrlStub.m
//  
//
//  Created by Chen XiaoLiang on 13-3-18.
//
//

#import "DCViewCtrlStub.h"

@implementation DCViewCtrlStub

@synthesize view = _view;
@synthesize viewCtrl = _viewCtrl;
@synthesize uniqueID = _uniqueID;

+ (NSString *)uniqueIDForViewCtrl:(UIViewController *)aViewCtrl {
    NSString *result = nil;
    do {
        if (!aViewCtrl) {
            break;
        }
        result = [NSString stringWithFormat:@"%8x", (NSUInteger)aViewCtrl];
    } while (NO);
    return result;
}

- (id)initWithView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl {
    if (!aView || !aViewCtrl) {
        return nil;
    }
    @synchronized(self) {
        self = [super init];
        if (self) {
            _viewCtrl = aViewCtrl;
            SAFE_ARC_RETAIN(_viewCtrl);
            _view = aView;
            SAFE_ARC_RETAIN(_view);
            _uniqueID = [DCViewCtrlStub uniqueIDForViewCtrl:aViewCtrl];
            SAFE_ARC_RETAIN(_uniqueID);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_view);
            SAFE_ARC_SAFERELEASE(_viewCtrl);
            SAFE_ARC_SAFERELEASE(_uniqueID);
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

@end
