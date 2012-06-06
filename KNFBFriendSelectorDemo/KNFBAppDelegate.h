//
//  KNFBAppDelegate.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

#define ApplicationDelegate ((KNFBAppDelegate *)[UIApplication sharedApplication].delegate)

@interface KNFBAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, FBSessionDelegate> {
  Facebook * facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
