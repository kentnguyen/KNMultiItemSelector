//
//  KNFBAppDelegate.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KNFBAppDelegate.h"

#import "KNFBFirstViewController.h"
#import "KNFBDemoBasicController.h"
#import "KNFBSecondViewController.h"

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
  if (![facebook isSessionValid]) {
    [SVProgressHUD show];
    [facebook authorize:[NSArray arrayWithObjects:@"user_about_me",@"friends_about_me", nil]];
  }

  // The tabs
  UIViewController *vc1 = [[KNFBDemoBasicController alloc] initWithNibName:@"KNFBDemoBasicController" bundle:nil];
  UIViewController *vc2 = [[KNFBFirstViewController alloc] initWithNibName:@"KNFBFirstViewController" bundle:nil];
  self.tabBarController = [[UITabBarController alloc] init];
  self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];

  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

#pragma mark - Facebook Session Delegate

- (void)fbDidLogin {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
  [SVProgressHUD dismissWithSuccess:@"Facebook"];
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

#pragma mark - Extending Facebook Token

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
  NSLog(@"TOKEN EXTENDED");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
  [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
}

@end
