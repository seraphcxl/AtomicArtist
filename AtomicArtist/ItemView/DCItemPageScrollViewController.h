//
//  DCItemPageScrollViewController.h
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCPageScrollViewController.h"
#import "DCItemView.h"
#import "DCItemViewController.h"

@interface DCItemPageScrollViewController : DCPageScrollViewController <DCItemViewDelegate, DCItemViewControllerDelegate>

- (IBAction)refresh:(id)sender;

@end
