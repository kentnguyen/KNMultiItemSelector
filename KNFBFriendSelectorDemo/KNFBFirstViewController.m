//
//  KNFBFirstViewController.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KNFBFirstViewController.h"
#import "KNFBAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

#import "KNMultiItemSelector.h"

@implementation KNFBFirstViewController
@synthesize textView;
@synthesize pickerButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Demo 1";
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
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
    [SVProgressHUD dismissWithError:@"Facebook Error"];
  }];
  [request startAsynchronous];
  [SVProgressHUD showWithStatus:@"Fetching friends"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Presenting the selector

- (IBAction)pickerButtonDidTouch:(id)sender {
  KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:friends
                                                             preselectedItems:nil
                                                                        title:@"Select friends"
                                                                     delegate:self];
  selector.useTableIndex = YES;
  UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
  uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
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
    textView.text = [textView.text stringByAppendingFormat:@"- ID %@\n", i.selectValue];
  }
}

#pragma mark - Memory

- (void)viewDidUnload {
  [self setPickerButton:nil];
  [super viewDidUnload];
}
@end
