//
//  DCViewCtrlStub.h
//  
//
//  Created by Chen XiaoLiang on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@interface DCViewCtrlStub : NSObject {
}

@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) UIView *view;
@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) UIViewController *viewCtrl;
@property (nonatomic, copy, readonly) NSString *uniqueID;

+ (NSString *)uniqueIDForViewCtrl:(UIViewController *)aViewCtrl;

- (id)initWithView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl;

@end
