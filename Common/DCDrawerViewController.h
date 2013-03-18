//
//  DCDrawerViewController.h
//  
//
//  Created by Chen XiaoLiang on 13-3-18.
//
//

#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

@class DCViewCtrlStub;

@interface DCDrawerViewController : UIViewController

@property (nonatomic, SAFE_ARC_PROP_STRONG, readonly) NSMutableDictionary *innerViewCtrlStubs;  // key:(NSString *) value:(DCViewCtrlStub *)

- (void)insertView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl;
- (void)removeView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl;

@end
