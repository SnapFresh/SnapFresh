//
//  AppDelegate.m
//  SnapFresh
//
//  Created by Marco Abundo on 1/18/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];

    splitViewController.delegate = (id)navigationController.topViewController;

    return YES;
}

@end
