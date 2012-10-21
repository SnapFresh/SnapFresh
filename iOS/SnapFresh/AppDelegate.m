/*
 * Copyright 2012 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Start up the Google Analytics tracker
    [[GANTracker sharedTracker] startTrackerWithAccountID:kGANAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    [[GANTracker sharedTracker] setDebug:YES];
    
    // Configure RestKit client
    [RKClient clientWithBaseURLString:kSnapFreshBaseURL];
    [[RKClient sharedClient] setTimeoutInterval:kSnapFreshTimeout];

    UIColor *color = [UIColor colorWithRed:0.39 green:0.60 blue:0.2 alpha:1.0];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];

        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    [[UIToolbar appearance] setTintColor:color];
    [[UISearchBar appearance] setTintColor:color];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Restart the Google Analytics tracker
    [[GANTracker sharedTracker] startTrackerWithAccountID:kGANAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[GANTracker sharedTracker] stopTracker];
}

@end
