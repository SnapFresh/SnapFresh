//
// EasyTracker.h
// Copyright 2011 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// The Easy Tracking library is a layer on top of the standard Google Analytics
// iOS SDK, and is designed to be used in lieu of the standard SDK calls in
// GANTracker.h. You should not use both the Easy Tracking library and the
// standard Google Analytics library, or you may experience unexpected behavior.
//
// To use the Easy Tracking library, you must provide account information and
// tracker settings in a configuration file named "EasyTracker.plist". This file
// must be in your application's resources. Within this file, you MUST define
// the following parameter with corresponding value:
//
// accountId
//   The account ID used to tracking application usage. Starts with "UA-".
//
// Additionally, you may define the following optional parameters:
//
// dispatchPeriod (defaults to 60)
//   The interval, in seconds, for schedule dispatching hits to Google
//   Analytics. Every |dispatchPeriod| seconds, the tracker will check to see
//   if there are buffered events needing submission. It is recommended to set
//   this value between 10 and 60, depending on your application. If this value
//   is zero or negative, events will be scheduled for dispatch immediately upon
//   receipt.
//
// debugEnabled (defaults to NO)
//   If YES, debugging information will be printed to the application log with
//   NSLog(). This information may be useful when debugging tracker problems.
//
// analyticsDisabled (defaults to NO)
//   If YES, calls to EasyTracker will be no-ops, and no tracking information
//   will be submitted to Google Analytics.  Defaults to NO.
//
// anonymizeIpEnabled (defaults to YES)
//   If YES, tracking information will be "anonymized" by setting the last octet
//   of the IP address to zero prior to storage or submission.
//
// sampleRate (defaults to 100)
//   An integer value between 0 and 100 used as a percentage to determine
//   whether an application instance will be sampled by Google Analytics. For
//   example, a value of 90 will result in there being a 90% chance that the
//   visitor will be sampled (and a 10% chance that they will not).
//
// On application launch, call "launchWithOptions:withParameters:andError" with
// the application's launch options and tracker options to start tracking your
// application.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EasyTracker : NSObject {
 @private
  NSDictionary *parameters_;
  NSDictionary *launchOptions_;
  int state_;
}

// 'launchWithOptions:withParameters:andError:' must be called from your
// application delegate's application:didFinishLaunchingWithOptions: method as
// follows:

/*
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [EasyTracker launchWithOptions:launchOptions
                  withParameters:nil
                       withError:nil];
*/

// Returns YES if an account ID was given, the tracker was not already tracking
// and was successfully started; NO otherwise.
+ (BOOL)launchWithOptions:(NSDictionary *)launchOptions
           withParameters:(NSDictionary *)trackerParameters
                withError:(NSError **)error;

@end

// You may override parameters from the plist by providing additional parameters
// in the tracker parameters dictionary using the keys provided below.
//
// For example, for development purposes, you may wish to use a separate account
// id so as to not pollute your production analytics numbers) and enable debug
// messages in the Google Analytics SDK. To accomplish this, provide
// the development account id and enable the debug flag as follows:

/*
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSMutableDictionary *trackerParameters =
      [NSMutableDictionary dictionaryWithCapacity:0];
  // Set custom parameters in |trackerParameters| here, before calling launch.
  [trackerParameters setValue:myDevAccountId
                       forKey:kGANAccountIdKey];
  [trackerParameters setValue:[NSNumber numberWithBool:TRUE]
                       forKey:kGANDebugEnabledKey];
  [EasyTracker launchWithOptions:launchOptions
                  withParameters:trackerParameters
                       withError:nil];
}
*/

// OPTIONAL: set the value for this key to an NSString containing the account id
// you wish to use. This will override the account id supplied in the plist.
extern NSString *const kGANAccountIdKey;

// OPTIONAL: set the value for this key to an NSNumber with the value of the
// dispatch period you wish to use. This will override the dispatch period
// supplied in the plist.
extern NSString *const kGANDispatchPeriodKey;

// OPTIONAL: set the value for this key to YES to enable debugging, or NO to
// disable it. This will override the setting supplied in the plist.
extern NSString *const kGANDebugEnabledKey;

// OPTIONAL: set the value for this key to YES to disable analytics, or NO to
// enable. This will override the setting supplied in the plist.
extern NSString *const kGANAnalyticsDisabledKey;

// OPTIONAL: set the value for this key to YES to enable anonymization, or NO
// to disable. This will override the setting supplied in the plist.
extern NSString *const kGANAnonymizeIpEnabledKey;

// OPTIONAL: set the value for this key to the desired sample rate (an integer
// between 0 and 100, inclusive). This will override the setting supplied in
// the plist.
extern NSString *const kGANSampleRateKey;

// OPTIONAL: set the value to a string containing the associated custom variable
// value.
// TODO(fmela): determine API for setting custom variables.
extern NSString *const kGANCustomVariable1;
extern NSString *const kGANCustomVariable2;
extern NSString *const kGANCustomVariable3;
extern NSString *const kGANCustomVariable4;
extern NSString *const kGANCustomVariable5;

/* Here are the contents of an example EasyTracker.plist file. You must replace
   the accountId with your Google Analytics account id before use.

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>accountId</key>
    <string>UA-00000000-1</string>
    <key>dispatchPeriod</key>
    <integer>30</integer>
    <key>debugEnabled</key>
    <false/>
</dict>
</plist>

*/

// Use TrackedUIViewController to automatically emit pageviews when the view
// associated with the controller appears. The EasyTracker will emit a pageview
// using the name of the view controller class as the URL. If you include a
// mapping from the view controller class to a desired pageview in your tracker
// parameters, the tracker will use that as the pageview URL instead. For
// example, your EasyTracker.plist file could include an entry like this:
//
//     <key>MapViewController</key>
//     <string>Map</string>
//
// This will generage pageviews for "Map", rather than for "MapViewController".
@interface TrackedUIViewController : UIViewController

// If you override this method, you must call [super viewDidAppear:animated] at
// some point in your implementation.
- (void)viewDidAppear:(BOOL)animated;

@end
