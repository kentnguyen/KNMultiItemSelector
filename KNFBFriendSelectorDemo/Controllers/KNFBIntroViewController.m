//
//  KNFBIntroViewController.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNFBIntroViewController.h"
#import "KNFBAppDelegate.h"

@implementation KNFBIntroViewController

-(IBAction)facebookButtonDidTouch:(id)sender {
  [ApplicationDelegate beginFacebookAuthorization];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
