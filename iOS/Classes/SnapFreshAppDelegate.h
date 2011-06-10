//
//  SnapFreshAppDelegate
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface SnapFreshAppDelegate : NSObject <UIApplicationDelegate>
{
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end