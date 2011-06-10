//
//  SnapFreshAppDelegate
//

#import "SnapFreshAppDelegate.h"
#import "MainViewController.h"

@implementation SnapFreshAppDelegate


@synthesize window;
@synthesize mainViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after application launch.
	
	// Set the main view controller as the window's root view controller and display.
    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];

    return YES;
}

- (void)dealloc
{
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end