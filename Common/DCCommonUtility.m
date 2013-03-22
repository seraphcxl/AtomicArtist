//
//  DCCommonUtility.m
//  
//
//  Created by Chen XiaoLiang on 13-1-31.
//
//

#import "DCCommonUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

@implementation DCCommonUtility

#pragma mark - DCCommonUtility - MD5
+ (NSString *)md5:(NSData *)data {
    NSString *result = nil;
    do {
        if (!data) {
            break;
        }
        unsigned char tmp[CC_MD5_DIGEST_LENGTH] = {0};
        CC_MD5(data.bytes, data.length, tmp);
        result = [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5], tmp[6], tmp[7], tmp[8], tmp[9], tmp[10], tmp[11], tmp[12], tmp[13], tmp[14], tmp[15]] lowercaseString];
    } while (NO);
    return result;
}

+ (BOOL)showPrompt:(PromptPopupType)type withTitles:(NSArray *)titles color:(UIColor *)titleColor font:(UIFont *)titleFont descriptions:(NSArray *)descs color:(UIColor *)descColor font:(UIFont *)descFont backgroundColor:(UIColor *)backgroundColor andDuration:(float)duration inViewController:(UIViewController *)vc atAnchor:(CGPoint)anchor andRadius:(CGFloat)radius withPopupOrientation:(PromptPopupOrientation)popupOrientation {
    BOOL result = NO;
    do {
        if (!vc) {
            break;
        }
        
        float durationForPrompt = duration > 0 ? duration : PROMPT_DURATION_SEC;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePromptInViewController:) object:vc];
        
        static NSUInteger s_labelCount = 0;
        
        UIView *promptView = [vc.view viewWithTag:TAG_VIEW_PROMPT];
        if (promptView != nil) {
            if (s_labelCount == [titles count] + [descs count]) {
                [self performSelector:@selector(hidePromptInViewController:) withObject:vc afterDelay:durationForPrompt inModes:[NSArray arrayWithObject: NSRunLoopCommonModes]];
                return NO;
            }
            
            UIView *viewLabels = [promptView viewWithTag:TAG_VIEW_PROMPT_LABEL];
            if (viewLabels) {
                [viewLabels removeFromSuperview];
            }
        }
        
        NSUInteger space = PROMPT_INNERSPACE;
        NSUInteger width = PROMPT_DEF_WIDTH;
        NSUInteger locY = PROMPT_EDGE_HEIGHT;
        
        s_labelCount = 0;
        NSMutableArray *arrayForTitle = [NSMutableArray array];
        NSMutableArray *arrayForDesc = [NSMutableArray array];
        if (titles) {
            UIColor *color = titleColor ? titleColor : [UIColor whiteColor];
            UIFont *font = titleFont ? titleFont : [UIFont boldSystemFontOfSize:PROMPT_TitleFontSize];
            for (NSString *title in titles) {
                UILabel *textPrompt = [[UILabel alloc] initWithFrame:CGRectZero];
                SAFE_ARC_AUTORELEASE(textPrompt);
                [textPrompt setBackgroundColor:[UIColor clearColor]];
                [textPrompt setFont:font];
                [textPrompt setTextColor:color];
                [textPrompt setText:title];
                textPrompt.textAlignment = NSTextAlignmentCenter;
                textPrompt.lineBreakMode = NSLineBreakByWordWrapping;
                textPrompt.numberOfLines = 0;
                
                CGSize labelSize = vc.view.bounds.size;
                labelSize.width *= 0.75f;
                labelSize.height *= 0.75f;
                CGSize fontSize =[title sizeWithFont:font constrainedToSize:labelSize lineBreakMode:UILineBreakModeWordWrap];
                if (fontSize.width > width) {
                    width = fontSize.width;
                }
                
                textPrompt.frame = CGRectMake(PROMPT_EDGE_WIDTH, locY, width, fontSize.height + space);
                
                [arrayForTitle addObject:textPrompt];
                locY += (fontSize.height + space);
                ++s_labelCount;
            }
        }        
        if (descs) {
            if ([arrayForTitle count] > 0) {
                locY += PROMPT_EDGE_HEIGHT;
            }
            UIColor *color = descColor ? descColor : [UIColor whiteColor];
            UIFont *font = descFont ? descFont : [UIFont systemFontOfSize:PROMPT_DetailFontSize];
            for (NSString *desc in descs) {
                UILabel *textPrompt = [[UILabel alloc] initWithFrame:CGRectZero];
                [textPrompt setBackgroundColor:[UIColor clearColor]];
                [textPrompt setFont:font];
                [textPrompt setTextColor:color];
                [textPrompt setText:desc];
                textPrompt.textAlignment = NSTextAlignmentCenter;
                textPrompt.lineBreakMode = NSLineBreakByWordWrapping;
                textPrompt.numberOfLines = 0;
                
                CGSize labelSize = vc.view.bounds.size;
                labelSize.width *= 0.75f;
                labelSize.height *= 0.75f;
                CGSize fontSize =[desc sizeWithFont:font constrainedToSize:labelSize lineBreakMode:UILineBreakModeWordWrap];
                if (fontSize.width > width) {
                    width = fontSize.width;
                }
                
                textPrompt.frame = CGRectMake(PROMPT_EDGE_WIDTH, locY, width, fontSize.height + space);
                
                [arrayForDesc addObject:textPrompt];
                locY += (fontSize.height + space);
                ++s_labelCount;
            }
        }
        
        CGRect boundsForSelf = vc.view.bounds;
        if (promptView) {
            SAFE_ARC_RETAIN(promptView);
            SAFE_ARC_AUTORELEASE(promptView);
            promptView.frame = CGRectMake(0, 0, width + PROMPT_EDGE_WIDTH * 2.f, locY + PROMPT_EDGE_HEIGHT);
//            promptView.center = CGPointMake(boundsForSelf.size.width / 2.f, boundsForSelf.size.height / 2.f);
            
            UIImageView *backgroundView = (UIImageView *)[promptView viewWithTag:TAG_VIEW_PROMPT_BACKGROUND];
            backgroundView.frame = CGRectMake(0, 0, width + PROMPT_EDGE_WIDTH * 2.f, locY + PROMPT_EDGE_HEIGHT);
            UIColor *color = backgroundColor ? backgroundColor : [UIColor colorWithRed:DC_RGB(0) green:DC_RGB(0) blue:DC_RGB(0) alpha:0.8f];
            backgroundView.backgroundColor = color;
        } else {
            promptView = [[UIView alloc] initWithFrame:vc.view.bounds];
            SAFE_ARC_AUTORELEASE(promptView);
//            promptView.center = CGPointMake(boundsForSelf.size.width / 2.f, boundsForSelf.size.height / 2.f);
            promptView.tag = TAG_VIEW_PROMPT;
            promptView.backgroundColor = [UIColor clearColor];
            promptView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            [vc.view addSubview:promptView];
        }
        
        UIView *viewLabels = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width + PROMPT_EDGE_WIDTH * 2.f, locY + PROMPT_EDGE_HEIGHT)];
        SAFE_ARC_AUTORELEASE(viewLabels);
        viewLabels.tag = TAG_VIEW_PROMPT_LABEL;
        [promptView addSubview:viewLabels];
        
        UIImageView *backgroundView = (UIImageView *)[promptView viewWithTag:TAG_VIEW_PROMPT_BACKGROUND];
        if (!backgroundView) {
            backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
            SAFE_ARC_AUTORELEASE(backgroundView);
            
            [viewLabels addSubview:backgroundView];
        }
        
        backgroundView.tag = TAG_VIEW_PROMPT_BACKGROUND;
        backgroundView.frame = CGRectMake(0, 0, width + PROMPT_EDGE_WIDTH * 2.f, locY + PROMPT_EDGE_HEIGHT);
        UIColor *color = backgroundColor ? backgroundColor : [UIColor colorWithRed:DC_RGB(0) green:DC_RGB(0) blue:DC_RGB(0) alpha:0.8f];
        backgroundView.backgroundColor = color;
        backgroundView.layer.cornerRadius = 8.0;
        backgroundView.layer.masksToBounds = YES;
        
        for (UILabel *label in arrayForTitle) {
            CGRect frame = label.frame;
            label.frame = CGRectMake(PROMPT_EDGE_WIDTH, frame.origin.y, width, frame.size.height);
            [viewLabels addSubview:label];
        }
        
        for (UILabel *label in arrayForDesc) {
            CGRect frame = label.frame;
            label.frame = CGRectMake(PROMPT_EDGE_WIDTH, frame.origin.y, width, frame.size.height);
            [viewLabels addSubview:label];
        }
        
        if ([vc respondsToSelector:@selector(hidePrompt:)]) {
            UITapGestureRecognizer *tapGRForHide = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(hidePrompt:)];
            tapGRForHide.cancelsTouchesInView = NO;
            [promptView addGestureRecognizer:tapGRForHide];
            SAFE_ARC_AUTORELEASE(tapGRForHide);
        }
        
        [self performSelector:@selector(hidePromptInViewController:) withObject:vc afterDelay:durationForPrompt inModes:[NSArray arrayWithObject: NSRunLoopCommonModes]];
        
        switch (type) {
            case PPT_Center:
            {
                viewLabels.center = CGPointMake(boundsForSelf.size.width / 2.f, boundsForSelf.size.height / 2.f);
            }
                break;
            case PPT_CustomLocation:
            {
                CGSize frameSize = viewLabels.bounds.size;
                switch (popupOrientation) {
                    case PPO_Top:
                    {
                        viewLabels.center = CGPointMake(anchor.x, anchor.y + radius + frameSize.height / 2.f);
                    }
                        break;
                    case PPO_Left:
                    {
                        viewLabels.center = CGPointMake(anchor.x - radius - frameSize.width / 2.f, anchor.y);
                    }
                        break;
                    case PPO_Bottom:
                    {
                        viewLabels.center = CGPointMake(anchor.x, anchor.y - radius - frameSize.height / 2.f);
                    }
                        break;
                    case PPO_Right:
                    {
                        viewLabels.center = CGPointMake(anchor.x + radius + frameSize.width / 2.f, anchor.y);
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
            {
                NSAssert(0, @"Unknown type!");
            }
                break;
        }
        CGRect labelsFrame = viewLabels.frame;
        if (labelsFrame.origin.x < 0) {
            labelsFrame.origin.x = 0;
        }
        if (labelsFrame.origin.y < 0) {
            labelsFrame.origin.y = 0;
        }
        if (labelsFrame.origin.x + labelsFrame.size.width > vc.view.bounds.size.width) {
            labelsFrame.origin.x -= (vc.view.bounds.size.width - labelsFrame.origin.x - labelsFrame.size.width);
        }
        if (labelsFrame.origin.y + labelsFrame.size.height > vc.view.bounds.size.height) {
            labelsFrame.origin.y -= (vc.view.bounds.size.height - labelsFrame.origin.y - labelsFrame.size.height);
        }
        viewLabels.frame = labelsFrame;
        
        promptView.alpha = 0.0f;
        [UIView animateWithDuration:.25f animations:^(void) {
            promptView.alpha = 1.0;
        } completion:^(BOOL finished) {
            promptView.alpha = 1.0;
        }];
        result = YES;
    } while (NO);
    return result;
}

+ (void)hidePromptInViewController:(UIViewController *)vc {
    do {
        if (!vc) {
            break;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePromptInViewController:) object:vc];
        UIView *view = [vc.view viewWithTag:TAG_VIEW_PROMPT];
        if (view) {
            [UIView animateWithDuration:.25f animations:^(void) {
                view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }
    } while (NO);
}

@end
