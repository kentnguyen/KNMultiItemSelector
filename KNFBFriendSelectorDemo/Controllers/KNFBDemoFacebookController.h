//
//  KNFBDemoFacebookController.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNMultiItemSelector.h"
#import "FBConnect.h"

@interface KNFBDemoFacebookController : UIViewController <KNMultiItemSelectorDelegate, FBRequestDelegate> {
  NSMutableArray * friends;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pickerButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *popoverButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *ipadOnlyLabel;
@property (strong, nonatomic) UIPopoverController * popoverController;

- (IBAction)popoverButtonDidTouch:(id)sender;
- (IBAction)pickerButtonDidTouch:(id)sender;

@end
