//
//  KNFBAppDelegate.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNFBAppDelegate.h"

#import "KNFBDemoFacebookController.h"
#import "KNFBDemoBasicController.h"
#import "KNFBIntroViewController.h"
#import "KNFBAboutViewController.h"

@implementation KNFBAppDelegate

@synthesize window = _window;
@synthesize facebook;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Init Facebook
  facebook = [[Facebook alloc] initWithAppId:@"316629235082530" andDelegate:self];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
    facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
  }

  // The tabs
  UIViewController *vc1 = [[KNFBDemoBasicController alloc] initWithNibName:@"KNFBDemoBasicController" bundle:nil];
  UIViewController *vc2 = [[KNFBDemoFacebookController alloc] initWithNibName:@"KNFBDemoFacebookController" bundle:nil];
  UIViewController *vc3 = [[KNFBAboutViewController alloc] initWithNibName:@"KNFBAboutViewController" bundle:nil];
  self.tabBarController = [[UITabBarController alloc] init];
  self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1, vc2, vc3, nil];
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];

  // Intro screen, connect to Facebook
  if (![facebook isSessionValid]) {
    [self.window.rootViewController presentModalViewController:[[KNFBIntroViewController alloc] initWithNibName:@"KNFBIntroViewController" bundle:nil]
                                                      animated:NO];
  }

  return YES;
}

-(void)beginFacebookAuthorization {
  [facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"friends_about_me", nil]];
}

#pragma mark - Standard Facebook stuff found in facebook-ios-sdk tutorial

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [facebook extendAccessTokenIfNeeded];
}

- (void)fbDidLogin {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];

  [SVProgressHUD dismissWithSuccess:@"Facebook"];
  [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
  [SVProgressHUD dismissWithError:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogout {}
- (void)fbSessionInvalidated {}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
  NSLog(@"TOKEN EXTENDED");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
  [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
}

@end
