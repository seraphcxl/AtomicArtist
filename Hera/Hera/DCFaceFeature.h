//
//  DCFaceFeature.h
//  
//
//  Created by Chen XiaoLiang on 13-1-25.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kDCFACEFEATURE_Scale_Top;
extern NSString * const kDCFACEFEATURE_Scale_Bottom;
extern NSString * const kDCFACEFEATURE_Scale_Left;
extern NSString * const kDCFACEFEATURE_Scale_Right;

@interface DCFaceFeature : NSObject <NSCoding>

@property (atomic, assign) float scaleTop;
@property (atomic, assign) float scaleBottom;
@property (atomic, assign) float scaleLeft;
@property (atomic, assign) float scaleRight;

+ (void)calcBoundingRectangle:(NSArray *)rectArray withTop:(float *)topRef bottom:(float *)bottomRef left:(float *)leftRef right:(float *)rightRef;

@end
