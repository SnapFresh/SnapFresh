//
//  FlipsideViewController
//

#import <MessageUI/MFMailComposeViewController.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) id <FlipsideViewControllerDelegate> delegate;

@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end