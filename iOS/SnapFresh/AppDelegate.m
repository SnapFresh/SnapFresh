/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    UIColor *color = [UIColor colorWithRed:0.39 green:0.60 blue:0.2 alpha:1.0];
    UIColor *whiteColor = [UIColor whiteColor];
    
    [[UIToolbar appearance] setTintColor:whiteColor];
    [[UIToolbar appearance] setBarTintColor:color];
    [[UIBarButtonItem appearance] setTintColor:whiteColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];

        splitViewController.delegate = (id)navigationController.topViewController;
    }
    else
    {
        [[UINavigationBar appearance] setBarTintColor:color];
    }

    return YES;
}

@end
