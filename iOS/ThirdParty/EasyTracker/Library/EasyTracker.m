//
// EasyTracker.m
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

#include "EasyTracker.h"

#include "GANTracker.h"

#pragma mark EasyTracker Constant Definitions

// The following keys are also used as keys when reading values from the plist.
NSString *const kGANAccountIdKey =          @"accountId";
NSString *const kGANDispatchPeriodKey =     @"dispatchPeriod";
NSString *const kGANDebugEnabledKey =       @"debugEnabled";
NSString *const kGANAnalyticsDisabledKey =  @"analyticsDisabled";
NSString *const kGANAnonymizeIpEnabledKey = @"anonymizeIpEnabled";
NSString *const kGANSampleRateKey =         @"sampleRate";
NSString *const kGANCustomVariable1 =       @"customVar1";
NSString *const kGANCustomVariable2 =       @"customVar2";
NSString *const kGANCustomVariable3 =       @"customVar3";
NSString *const kGANCustomVariable4 =       @"customVar4";
NSString *const kGANCustomVariable5 =       @"customVar5";

// Private constants and defaults.
static NSString *const kPropertyFileName = @"EasyTracker";
static const NSInteger kDefaultDispatchPeriod = 60;
static const BOOL kDefaultDebugEnabled = NO;
static const BOOL kDefaultAnalyticsDisabled = NO;
static const BOOL kDefaultAnonymizeIpEnabled = YES;
static const NSInteger kDefaultSampleRate = 100;
static NSString *const kDefaultAccountId = @"UA-00000000-1";

enum EasyTrackerState {
  EasyTrackerStateNotTracking,
  EasyTrackerStateForeground,
  EasyTrackerStateBackground,
};

#pragma mark EasyTracker Continuation Method Declarations

@interface EasyTracker ()

+ (EasyTracker *)sharedTracker;

- (NSString *)getPageviewName:(NSString *)className;

- (NSString *)getStringParameter:(NSString *)key
                    defaultValue:(NSString *)defaultValue
                     description:(NSString *)description;

- (NSInteger)getIntegerParameter:(NSString *)key
                    defaultValue:(NSInteger)defaultValue
                     description:(NSString *)description;

- (BOOL)getBoolParameter:(NSString *)key
            defaultValue:(BOOL)defaultValue
             description:(NSString *)description;

- (NSError *)errorWithCode:(NSInteger)code
            andDescription:(NSString *)description;

- (NSString *)appStateString:(UIApplicationState)state;

- (BOOL)parseParametersAndStartTracker:(NSError **)error;
- (void)dispatchViewDidAppear:(NSString *)controllerClassName;
- (void)applicationWillTerminate:(NSNotification *)notification;
- (void)applicationStateChanged:(NSNotification *)notification;

@property (nonatomic, readwrite, retain) NSDictionary *parameters;
@property (nonatomic, readwrite, copy)   NSDictionary *launchOptions;
@property (nonatomic, readwrite, assign) int state;

@end

#pragma mark EasyTracker Implementation

// Singleton instance of EasyTracker.
static EasyTracker *sSharedTracker = nil;

@implementation EasyTracker

@synthesize parameters = parameters_;
@synthesize launchOptions = launchOptions_;
@synthesize state = state_;

- (id)init {
  self = [super init];
  if (self) {
    self.parameters = nil;
    self.launchOptions = nil;
    self.state = EasyTrackerStateNotTracking;
  }
  return self;
}

+ (BOOL)launchWithOptions:(NSDictionary *)launchOptions
           withParameters:(NSDictionary *)trackerParameters
                withError:(NSError **)error {
  EasyTracker *easyTracker = [EasyTracker sharedTracker];
  if (easyTracker.state != EasyTrackerStateNotTracking) {
    return NO;
  }
  // TODO(fmela): do something useful with application launch options. Most
  // useful would be tracking launch method (direct, notification, URL, etc).
  easyTracker.launchOptions = launchOptions;

  // Load all values from the plist file into a dictionary.
  NSString *filePath =
      [[NSBundle mainBundle] pathForResource:kPropertyFileName ofType:@"plist"];
  NSMutableDictionary *parameters;
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSLog(@"ERROR: %@.plist not found! Attempting to continue.",
          kPropertyFileName);
    // The account ID will need to be supplied in |trackerParameters|.
    parameters = [NSMutableDictionary dictionaryWithCapacity:0];
  } else {
    parameters = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
  }

  // Add in the options supplied in |trackerParameters|. In case of collision,
  // the value from |trackerParameters| will override the plist value.
  [parameters addEntriesFromDictionary:trackerParameters];
  easyTracker.parameters = parameters;

  NSString *accountId =
      [easyTracker getStringParameter:kGANAccountIdKey
                         defaultValue:nil
                          description:@"account id"];
  if (accountId == nil) {
    if (error) {
      *error = [easyTracker errorWithCode:kGANTrackerInvalidInputError
                           andDescription:@"Missing or invalid Account ID."];
    }
    return NO;
  }
  if ([accountId isEqualToString:kDefaultAccountId]) {
    NSLog(@"You must provide your own Google Analytics account ID.");
    if (error) {
      *error = [easyTracker errorWithCode:kGANTrackerInvalidInputError
                           andDescription:@"Invalid Account ID given."];
    }
    return NO;
  }

  // Check if analytics is disabled. If so, return success.
  BOOL analyticsDisabled =
      [easyTracker getBoolParameter:kGANAnalyticsDisabledKey
                       defaultValue:kDefaultAnalyticsDisabled
                        description:@"analytics disabled"];
  if (analyticsDisabled) {
    NSLog(@"Google Analytics Disabled.");
    return YES;
  }

  UIApplication *application = [UIApplication sharedApplication];
  if ([application applicationState] == UIApplicationStateActive) {
    easyTracker.state = EasyTrackerStateForeground;
  } else {
    easyTracker.state = EasyTrackerStateBackground;
  }

  // Register easyTracker for application lifecycle notifications. The
  // EasyTracker singleton will never be dealloced, so we never need to
  // unregister for notifications.
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

  [defaultCenter addObserver:easyTracker
                    selector:@selector(applicationWillTerminate:)
                        name:UIApplicationWillTerminateNotification
                      object:[UIApplication sharedApplication]];

  [defaultCenter addObserver:easyTracker
                    selector:@selector(applicationStateChanged:)
                        name:UIApplicationWillEnterForegroundNotification
                      object:[UIApplication sharedApplication]];

  [defaultCenter addObserver:easyTracker
                    selector:@selector(applicationStateChanged:)
                        name:UIApplicationDidEnterBackgroundNotification
                      object:[UIApplication sharedApplication]];

  [defaultCenter addObserver:easyTracker
                    selector:@selector(applicationStateChanged:)
                        name:UIApplicationWillResignActiveNotification
                      object:[UIApplication sharedApplication]];

  [defaultCenter addObserver:easyTracker
                    selector:@selector(applicationStateChanged:)
                        name:UIApplicationDidBecomeActiveNotification
                      object:[UIApplication sharedApplication]];

  return YES;
}

- (BOOL)parseParametersAndStartTracker:(NSError **)error {
  // Determine whether to enable debug messages first.
  BOOL debugEnabled =
      [self getBoolParameter:kGANDebugEnabledKey
                defaultValue:kDefaultDebugEnabled
                 description:@"debug enabled"];
  [GANTracker sharedTracker].debug = debugEnabled;
  if (debugEnabled) {
    NSLog(@"Google Analytics SDK debugging enabled.");
  }

  NSString *accountId =
      [self getStringParameter:kGANAccountIdKey
                  defaultValue:nil
                   description:@"account id"];
  if (accountId == nil) {
    if (error) {
      *error = [self errorWithCode:kGANTrackerInvalidInputError
                    andDescription:@"Missing or invalid Account ID."];
    }
    return NO;
  }
  if ([accountId isEqualToString:@"UA-00000000-1"]) {
    NSLog(@"You must provide your own Google Analytics account ID.");
    if (error) {
      *error = [self errorWithCode:kGANTrackerInvalidInputError
                    andDescription:@"Invalid Account ID given."];
    }
    return NO;
  }
  if (debugEnabled) {
    NSLog(@"Account ID set to: %@", accountId);
  }

  NSInteger dispatchPeriod =
      [self getIntegerParameter:kGANDispatchPeriodKey
                   defaultValue:kDefaultDispatchPeriod
                    description:@"dispatch period"];
  if (dispatchPeriod < 0) {
    dispatchPeriod = 0;
  }
  if (debugEnabled) {
    NSLog(@"Dispatch period set to: %d", dispatchPeriod);
  }

  BOOL anonymizeIpEnabled =
      [self getBoolParameter:kGANAnonymizeIpEnabledKey
       defaultValue:kDefaultAnonymizeIpEnabled
        description:@"anonymize IP enabled"];
  if (debugEnabled) {
    NSLog(@"Anonymize IP Enabled set to %s", anonymizeIpEnabled ? "YES" : "NO");
  }

  NSInteger sampleRate =
      [self getIntegerParameter:kGANSampleRateKey
                   defaultValue:kDefaultSampleRate
                    description:@"sample rate"];
  if (sampleRate < 0) {
    sampleRate = 0;
  } else if (sampleRate > 100) {
    sampleRate = 100;
  }
  if (debugEnabled) {
    NSLog(@"Sample rate set to: %d", sampleRate);
  }

  [GANTracker sharedTracker].anonymizeIp = anonymizeIpEnabled;
  [GANTracker sharedTracker].sampleRate = sampleRate;
  [[GANTracker sharedTracker] startTrackerWithAccountID:accountId
                                         dispatchPeriod:dispatchPeriod
                                               delegate:nil];
  NSLog(@"Tracker started!");

  return YES;
}

- (void)dispatchViewDidAppear:(NSString *)controllerClassName {
  if (self.state == EasyTrackerStateNotTracking) {
    return;
  }
  NSString *pageviewName = [self getPageviewName:controllerClassName];
  [[GANTracker sharedTracker] trackPageview:pageviewName withError:nil];
  if ([GANTracker sharedTracker].debug) {
    NSLog(@"Dispatched %@ pageview for tracked view controller %@",
          pageviewName, controllerClassName);
  }
}

#pragma mark EasyTracker Utility methods

- (NSString *)getPageviewName:(NSString *)className {
  return [self getStringParameter:className
                     defaultValue:className
                      description:@"display name for view controller"];
}

- (NSString *)getStringParameter:(NSString *)key
                    defaultValue:(NSString *)defaultValue
                     description:(NSString *)description {
  NSObject *object = [self.parameters objectForKey:key];
  if (object == nil) {
    return defaultValue;
  }
  if (![object isKindOfClass:[NSString class]]) {
    NSLog(@"Invalid object supplied for %@ setting: need NSString, got %@.",
          description, NSStringFromClass([object class]));
    return defaultValue;
  }
  return (NSString *)object;
}

- (NSInteger)getIntegerParameter:(NSString *)key
                    defaultValue:(NSInteger)defaultValue
                     description:(NSString *)description {
  NSObject *object = [self.parameters objectForKey:key];
  if (object == nil) {
    return defaultValue;
  }
  if (![object isKindOfClass:[NSNumber class]]) {
    NSLog(@"Invalid object supplied for %@ setting: need NSNumber, got %@.",
          description, NSStringFromClass([object class]));
    return defaultValue;
  }
  return [(NSNumber *)object integerValue];
}

- (BOOL)getBoolParameter:(NSString *)key
            defaultValue:(BOOL)defaultValue
             description:(NSString *)description {
  NSObject *object = [self.parameters objectForKey:key];
  if (object == nil) {
    return defaultValue;
  }
  if (![object isKindOfClass:[NSNumber class]]) {
    NSLog(@"Invalid object supplied for %@ setting: need NSNumber, got %@.",
          description, NSStringFromClass([object class]));
    return defaultValue;
  }
  return [(NSNumber *)object boolValue] != NO;
}

- (NSError *)errorWithCode:(NSInteger)code
            andDescription:(NSString *)description {
  return [NSError errorWithDomain:kGANTrackerErrorDomain
                             code:code
                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                  NSLocalizedDescriptionKey, description, nil]];
}

- (NSString *)appStateString:(UIApplicationState)state {
  switch (state) {
    case UIApplicationStateActive:
      return @"Active";

    case UIApplicationStateInactive:
      return @"Inactive";

    case UIApplicationStateBackground:
      return @"Background";

    default:
      return @"Unknown";
  }
}

#pragma mark EasyTracker Application State Change Notifications

- (void)applicationStateChanged:(NSNotification *)notification {
  UIApplication* application = [notification object];
  NSLog(@"Notified of %@ (application state %@)", [notification name],
        [self appStateString:[application applicationState]]);

  if (self.state == EasyTrackerStateNotTracking) {
    NSLog(@"Unexpected application state change notification: %@",
          [notification name]);
    return;
  }

  if ([application applicationState] == UIApplicationStateActive) {
    if (self.state == EasyTrackerStateBackground) {
      // Transitioned from background to foreground. Restart tracker, and
      // generate the app start event.
      NSLog(@"Transitioned from background to foreground.");
      NSError *error = nil;
      if (![self parseParametersAndStartTracker:&error]) {
        NSLog(@"Failed to start tracking: %@", error);
      } else if (![[GANTracker sharedTracker] trackEvent:@""
                                                  action:@""
                                                   label:@""
                                                   value:0
                                               withError:&error]) {
        NSLog(@"Error tracking foreground event: %@", error);
      }
    }
    self.state = EasyTrackerStateForeground;
  } else if ([application applicationState] == UIApplicationStateBackground) {
    if (self.state == EasyTrackerStateForeground) {
      // Transitioned from foreground to background. Generate the app stop
      // event, and stop the tracker.
      NSLog(@"Transitioned from foreground to background.");
      NSError *error = nil;
      if (![[GANTracker sharedTracker] trackEvent:@""
                                           action:@""
                                            label:@""
                                            value:0
                                        withError:&error]) {
        NSLog(@"Error tracking foreground event: %@", error);
      }
      // TODO(fmela): make this time period a constant.
      if (![[GANTracker sharedTracker] dispatchSynchronous:2.0]) {
        NSLog(@"Synchronous dispatch on background failed!");
      }
      [[GANTracker sharedTracker] stopTracker];
    }
    self.state = EasyTrackerStateBackground;
  }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  UIApplication* application = [notification object];
  NSLog(@"Notified of %@ (application state %@)", [notification name],
        [self appStateString:[application applicationState]]);

  if (self.state != EasyTrackerStateNotTracking) {
    NSLog(@"Dispatching pending hits synchronously...");
    // TODO(fmela): make this time period a constant.
    [[GANTracker sharedTracker] dispatchSynchronous:2.0];
    NSLog(@"... dispatch complete.");
    [[GANTracker sharedTracker] stopTracker];
    self.state = EasyTrackerStateNotTracking;
  }
}

#pragma mark SingletonBoilerPlate

+ (EasyTracker *)sharedTracker {
  @synchronized(self) {
    if (sSharedTracker == nil) {
      sSharedTracker = [[self alloc] init];
    }
  }
  return sSharedTracker;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sSharedTracker == nil) {
      sSharedTracker = [super allocWithZone:zone];
      return sSharedTracker;
    }
  }

  return nil;
}

- (id)retain {
  return self;
}

- (NSUInteger)retainCount {
  return NSUIntegerMax;
}

- (oneway void)release {
}

- (id)autorelease {
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

@end  // EasyTracker

#pragma mark TrackedUIViewController

@implementation TrackedUIViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // Determine the class name of this view controller using reflection.
  NSString *className = NSStringFromClass([self class]);
  [[EasyTracker sharedTracker] dispatchViewDidAppear:className];
}

@end  // TrackedUIViewController
