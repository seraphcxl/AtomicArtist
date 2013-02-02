//
//  DCFaceFeature.m
//  
//
//  Created by Chen XiaoLiang on 13-1-25.
//
//

#import "DCFaceFeature.h"

NSString * const kDCFACEFEATURE_Scale_Top = @"DCFACEFEATURE_Scale_Top";
NSString * const kDCFACEFEATURE_Scale_Bottom = @"DCFACEFEATURE_Scale_Bottom";
NSString * const kDCFACEFEATURE_Scale_Left = @"DCFACEFEATURE_Scale_Left";
NSString * const kDCFACEFEATURE_Scale_Right = @"DCFACEFEATURE_Scale_Right";

@implementation DCFaceFeature

@synthesize scaleTop = _scaleTop;
@synthesize scaleBottom = _scaleBottom;
@synthesize scaleLeft = _scaleLeft;
@synthesize scaleRight = _scaleRight;

+ (void)calcBoundingRectangle:(NSArray *)rectArray withTop:(float *)topRef bottom:(float *)bottomRef left:(float *)leftRef right:(float *)rightRef {
    do {
        if (!topRef || !bottomRef || !leftRef || !rightRef) {
            break;
        }
        
        NSUInteger idx = 0;
        for (DCFaceFeature *feature in rectArray) {
            if (idx == 0) {
                *topRef = feature.scaleTop;
                *bottomRef = feature.scaleBottom;
                *leftRef = feature.scaleLeft;
                *rightRef = feature.scaleRight;
            } else {
                *topRef = MIN(*topRef, feature.scaleTop);
                *bottomRef = MAX(*bottomRef, feature.scaleBottom);
                *leftRef = MIN(*leftRef, feature.scaleLeft);
                *rightRef = MAX(*rightRef, feature.scaleRight);
            }
            ++idx;
        }
    } while (NO);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @synchronized(self) {
        if (!aDecoder) {
            return nil;
        }
        
        self = [super init];
        if (self) {
            _scaleTop = [aDecoder decodeFloatForKey:kDCFACEFEATURE_Scale_Top];
            _scaleBottom = [aDecoder decodeFloatForKey:kDCFACEFEATURE_Scale_Bottom];
            _scaleLeft = [aDecoder decodeFloatForKey:kDCFACEFEATURE_Scale_Left];
            _scaleRight = [aDecoder decodeFloatForKey:kDCFACEFEATURE_Scale_Right];
        }
        return self;
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    do {
        @synchronized(self) {
            if (!aCoder) {
                break;
            }
            [aCoder encodeFloat:self.scaleTop forKey:kDCFACEFEATURE_Scale_Top];
            [aCoder encodeFloat:self.scaleBottom forKey:kDCFACEFEATURE_Scale_Bottom];
            [aCoder encodeFloat:self.scaleLeft forKey:kDCFACEFEATURE_Scale_Left];
            [aCoder encodeFloat:self.scaleRight forKey:kDCFACEFEATURE_Scale_Right];
        }
    } while (NO);
}

@end
