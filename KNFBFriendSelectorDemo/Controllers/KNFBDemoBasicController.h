//
//  KNFBDemoBasicController.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KNMultiItemSelector.h"

@interface KNFBDemoBasicController : UIViewController <KNMultiItemSelectorDelegate> {
  NSMutableArray * items;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *resultLabel;

- (IBAction)basicButtonDidTouch:(id)sender;
- (IBAction)indexButtonDidTouch:(id)sender;
- (IBAction)recentButtonDidTouch:(id)sender;

@end
