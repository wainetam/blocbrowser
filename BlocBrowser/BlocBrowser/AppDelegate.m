//
//  AppDelegate.m
//  BlocBrowser
//
//  Created by Waine Tam on 1/27/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AppDelegate.h"
#import "WebBrowserViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[WebBrowserViewController alloc] init]];
    
    [self.window makeKeyAndVisible];
    
    [self showWelcomeMessage];
    
    return YES;
}

- (void)showWelcomeMessage {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
                                                                   message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction: defaultAction];
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
// QUESTION: error: Attempt to present <UIAlertController: 0x12f50b9e0> on <UINavigationController: 0x12f60c8e0> whose view is not in the window hierarchy!
    
//    QUESTION: 'displays the receiver' terminology q -- receiver? is that the receiver of the message; and how to you tell on which VC this is presented?
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
//                                                    message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment")
//                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title")
//                                          otherButtonTitles:nil];
//    [alert show];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    UINavigationController *navigationVC = (UINavigationController *)self.window.rootViewController;
    WebBrowserViewController *browserVC = [[navigationVC viewControllers] firstObject];
    [browserVC resetWebView];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
