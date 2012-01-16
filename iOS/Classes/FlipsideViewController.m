//
//  FlipsideViewController
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "FlipsideViewController.h"

@interface FlipsideViewController () // Class extension
@property (nonatomic, unsafe_unretained) IBOutlet UISegmentedControl *mapSegmentedControl;
- (IBAction)done:(id)sender;
- (IBAction)showMailPicker:(id)sender;
- (void)changeType:(id)sender;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
@end

@implementation FlipsideViewController

@synthesize mapSegmentedControl, delegate;

int mailType = 0;
static int FEEDBACK = 0;
static int RECOMMMEND = 1;

static NSString *feedbackRecipient = @"shrtlist@gmail.com";
static NSString *feedbackSubject = @"SnapFresh feedback";

static NSString *recommendSubject = @"Check out SnapFresh on iTunes";
static NSString *recommendBody = @"Please check out SnapFresh:\n\nhttp://www.snapfresh.org";

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	MainViewController *viewController = (MainViewController *)self.delegate;
	
	if ([viewController.mapView mapType] == MKMapTypeStandard)
	{
		[mapSegmentedControl setSelectedSegmentIndex:0];
	}
	else if ([viewController.mapView mapType] == MKMapTypeSatellite)
	{
		[mapSegmentedControl setSelectedSegmentIndex:1];
	}
	else if ([viewController.mapView mapType] == MKMapTypeHybrid)
	{
		[mapSegmentedControl setSelectedSegmentIndex:2];
	}
}


#pragma mark -
#pragma mark Button actions

- (IBAction)done:(id)sender
{
	[self changeType:sender];
	[self.delegate flipsideViewControllerDidFinish:self];	
}

-(IBAction)showMailPicker:(id)sender
{
	NSString *buttonText = ((UIButton *)sender).currentTitle;
	
	// Kludge for now
	if ([buttonText isEqualToString:@"Send feedback"])
	{
		mailType = FEEDBACK;
	}
	else
	{
		mailType = RECOMMMEND;
	}

	// This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = NSClassFromString(@"MFMailComposeViewController");
	
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

#pragma mark -
#pragma mark Change the map type based on user selection

- (void)changeType:(id)sender
{
	MainViewController *viewController = (MainViewController *)self.delegate;
    
	if ([mapSegmentedControl selectedSegmentIndex] == 0)
	{
		[viewController.mapView setMapType:MKMapTypeStandard];
	}
	else if ([mapSegmentedControl selectedSegmentIndex] == 1)
	{
		[viewController.mapView setMapType:MKMapTypeSatellite];
	}
	else if ([mapSegmentedControl selectedSegmentIndex] == 2)
	{
		[viewController.mapView setMapType:MKMapTypeHybrid];
	}
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	[picker setMailComposeDelegate:self];
	
	if (mailType == FEEDBACK)
	{
		// Set up recipients
		NSArray *toRecipients = [NSArray arrayWithObject:feedbackRecipient];
		[picker setToRecipients:toRecipients];
		[picker setSubject:feedbackSubject];
	}
	else
	{
		[picker setSubject:recommendSubject];
		[picker setMessageBody:recommendBody isHTML:NO];
	}

	[self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

// Workaround that launches the Mail application on the device.
- (void)launchMailAppOnDevice
{
	NSString *email = nil;
	
	if (mailType == FEEDBACK)
	{
		email = [NSString stringWithFormat:@"mailto:%@?subject=%@", feedbackRecipient, feedbackSubject];
	}
	else
	{
		email = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", recommendSubject, recommendBody];
	}

	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

@end