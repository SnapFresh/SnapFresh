//
//  SnapFreshAppDelegate
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface SnapFreshAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *mainViewController;

@end