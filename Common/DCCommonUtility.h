//
//  DCCommonUtility.h
//  
//
//  Created by Chen XiaoLiang on 13-1-31.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCCommonConstants.h"
#import "SafeARC.h"

#define PROMPT_DEF_WIDTH (64)
#define PROMPT_DEF_HEIGHT (24)
#define PROMPT_INNERSPACE (4)
#define PROMPT_EDGE_WIDTH (8)
#define PROMPT_EDGE_HEIGHT (8)
#define PROMPT_TitleFontSize (18)
#define PROMPT_DetailFontSize (14)
#define PROMPT_DURATION_SEC (3.f)

#define TAG_VIEW_PROMPT 32101
#define TAG_VIEW_PROMPT_LABEL 32102
#define TAG_VIEW_PROMPT_BACKGROUND 32103
#define TAG_VIEW_PROMPT_TAPCTRL 32104

typedef enum {
    PPT_Center = 0,
    PPT_CustomLocation,
} PromptPopupType;

typedef enum {
    PPO_Top = 0,
    PPO_Left,
    PPO_Bottom,
    PPO_Right,
} PromptPopupOrientation;

@interface DCCommonUtility : NSObject

#pragma mark - DCCommonUtility - MD5
+ (NSString *)md5:(NSData *)data;

+ (BOOL)showPrompt:(PromptPopupType)type withTitles:(NSArray *)titles color:(UIColor *)titleColor font:(UIFont *)titleFont descriptions:(NSArray *)descs color:(UIColor *)descColor font:(UIFont *)descFont backgroundColor:(UIColor *)backgroundColor andDuration:(float)duration inViewController:(UIViewController *)vc atAnchor:(CGPoint)anchor andRadius:(CGFloat)radius withPopupOrientation:(PromptPopupOrientation)popupOrientation;
+ (void)hidePromptInViewController:(UIViewController *)vc;

@end
