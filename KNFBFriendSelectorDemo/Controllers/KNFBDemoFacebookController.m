//
//  KNFBDemoFacebookController.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNFBDemoFacebookController.h"
#import "KNFBAppDelegate.h"

#import "KNMultiItemSelector.h"

@implementation KNFBDemoFacebookController
@synthesize textView;
@synthesize pickerButton;
@synthesize popoverButton;
@synthesize ipadOnlyLabel;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"FB Friends";
    self.tabBarItem.image = [UIImage imageNamed:@"TabFacebook"];
    friends = [NSMutableArray array];
  }
  return self;
}

#pragma mark - Fetch Facebook friends
							
- (void)viewDidLoad {
  [super viewDidLoad];
  ipadOnlyLabel.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

  // Fetch all facebook friends and store in NSArray
  [ApplicationDelegate.facebook requestWithGraphPath:@"me/friends" andDelegate:self];
  [SVProgressHUD showWithStatus:@"Fetching friends" maskType:SVProgressHUDMaskTypeGradient];
}


#pragma mark - Handle Facebook request data

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
  [SVProgressHUD showErrorWithStatus:@"Facebook error, try again!"];
  [SVProgressHUD dismissWithError:nil afterDelay:10];
}


- (void)request:(FBRequest *)request didLoad:(id)result {
  [SVProgressHUD dismiss];
  pickerButton.hidden = NO;
  popoverButton.hidden = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;

  NSDictionary * rawObject = result;
  NSArray * dataArray = [rawObject objectForKey:@"data"];
  for (NSDictionary * f in dataArray) {
    [friends addObject:[[KNSelectorItem alloc] initWithDisplayValue:[f objectForKey:@"name"]
                                                        selectValue:[f objectForKey:@"id"]
                                                           imageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [f objectForKey:@"id"]]]];
  }
  [friends sortUsingSelector:@selector(compareByDisplayValue:)];
}

#pragma mark - Presenting the selector

- (IBAction)pickerButtonDidTouch:(id)sender {

  // You can even change the title and placeholder text for the selector
  KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:friends
                                                             preselectedItems:nil
                                                                        title:@"Select friends"
                                                              placeholderText:@"Search by name"
                                                                     delegate:self];
  // Again, the two optional settings
  selector.allowSearchControl = YES;
  selector.useTableIndex      = YES;
  selector.useRecentItems     = YES;
  selector.maxNumberOfRecentItems = 4;
  selector.allowModeButtons = NO;
  UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
  uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  uinav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentModalViewController:uinav animated:YES];
}


- (IBAction)popoverButtonDidTouch:(id)sender {
  // Same code as above
  KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:friends
                                                             preselectedItems:nil
                                                                        title:@"Select friends"
                                                              placeholderText:@"Search by name"
                                                                     delegate:self];
  selector.allowSearchControl = YES;
  selector.useTableIndex      = YES;
  selector.useRecentItems     = YES;
  selector.maxNumberOfRecentItems = 8;

  // But different way of presenting only for iPad
  UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
  self.popoverController = [[UIPopoverController alloc] initWithContentViewController:uinav];
  [self.popoverController presentPopoverFromRect:popoverButton.frame
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Handle delegate callback

-(void)selectorDidCancelSelection {
  [self dismissModalViewControllerAnimated:YES];
  if (self.popoverController) {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
  }
}

-(void)selectorDidFinishSelectionWithItems:(NSArray *)selectedItems {
  [self dismissModalViewControllerAnimated:YES];
  if (self.popoverController) {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
  }

  textView.text = selectedItems.count ? @"You have selected:\n" : @"You have not selected any friend";
  for (KNSelectorItem * i in selectedItems) {
    textView.text = [textView.text stringByAppendingFormat:@"%@ - %@\n", i.selectValue, i.displayValue];
  }
}

#pragma mark - Memory

- (void)viewDidUnload {
  [self setPickerButton:nil];
  [self setPopoverButton:nil];
  [self setIpadOnlyLabel:nil];
  [self setPopoverController:nil];
  [super viewDidUnload];
}
@end
