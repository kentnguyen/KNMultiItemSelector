//
//  KNFBDemoFacebookController.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNMultiItemSelector.h"

@interface KNFBDemoFacebookController : UIViewController <KNMultiItemSelectorDelegate> {
  NSMutableArray * friends;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pickerButton;

- (IBAction)pickerButtonDidTouch:(id)sender;

@end
