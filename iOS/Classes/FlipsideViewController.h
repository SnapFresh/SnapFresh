//
//  FlipsideViewController
//

#import <MessageUI/MFMailComposeViewController.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapSegmentedControl;


- (IBAction)done:(id)sender;
- (IBAction)showMailPicker:(id)sender;

@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end