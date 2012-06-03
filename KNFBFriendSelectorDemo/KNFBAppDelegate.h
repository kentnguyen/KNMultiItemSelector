//
//  KNFBAppDelegate.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface KNFBAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, FBSessionDelegate> {
  Facebook * facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
