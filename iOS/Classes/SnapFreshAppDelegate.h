//
//  SnapFreshAppDelegate
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface SnapFreshAppDelegate : NSObject <UIApplicationDelegate>

/**
 * The object graph includes all of the windows, views, controls, cells, menus,
 * and custom objects found in the nib file.
 *
 * Top-level objects are the subset of objects that do not have a parent object.
 * The top-level objects typically include only the windows and custom controller
 * objects added to the nib file. 
 *
 * Keep a pointer to these objects because our application is responsible for 
 * releasing them when done.
 */
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *mainViewController;

@end