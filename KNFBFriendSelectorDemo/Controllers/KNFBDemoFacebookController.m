//
//  KNFBDemoFacebookController.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNFBDemoFacebookController.h"
#import "KNFBAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

#import "KNMultiItemSelector.h"

@implementation KNFBDemoFacebookController
@synthesize textView;
@synthesize pickerButton;

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

  // Fetch all facebook friends and store in NSArray
  NSString * ogEndpoint = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", ApplicationDelegate.facebook.accessToken];
  ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:ogEndpoint]];
  [request setCompletionBlock:^{
    [SVProgressHUD dismiss];
    pickerButton.hidden = NO;

    NSDictionary * rawObject = [request.responseString objectFromJSONString];
    NSArray * dataArray = [rawObject objectForKey:@"data"];
    for (NSDictionary * f in dataArray) {
      [friends addObject:[[KNSelectorItem alloc] initWithDisplayValue:[f objectForKey:@"name"]
                                                          selectValue:[f objectForKey:@"id"]
                                                             imageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [f objectForKey:@"id"]]]];
    }
    [friends sortUsingSelector:@selector(compareByDisplayValue:)];
  }];
  [request setFailedBlock:^{
    [SVProgressHUD showErrorWithStatus:@"Facebook error, try again!"];
    [SVProgressHUD dismissWithError:nil afterDelay:10];
  }];
  [request startAsynchronous];
  [SVProgressHUD showWithStatus:@"Fetching friends"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
  UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
  uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  uinav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentModalViewController:uinav animated:YES];
}

#pragma mark - Handle delegate callback

-(void)selectorDidCancelSelection {
  [self dismissModalViewControllerAnimated:YES];
}

-(void)selectorDidFinishSelectionWithItems:(NSArray *)selectedItems {
  [self dismissModalViewControllerAnimated:YES];

  textView.text = @"You have selected:\n";
  for (KNSelectorItem * i in selectedItems) {
    textView.text = [textView.text stringByAppendingFormat:@"%@ - %@\n", i.selectValue, i.displayValue];
  }
}

#pragma mark - Memory

- (void)viewDidUnload {
  [self setPickerButton:nil];
  [super viewDidUnload];
}
@end
