//
//  MainViewController
//

#import "MainViewController.h"
#import "ForwardGeocoder.h"
#import "ResponseParser.h"
#import "Reachability.h"

@interface MainViewController ()

- (NSArray *)getNearbyAddresses:(NSString *)address;

@end


@implementation MainViewController

@synthesize mapView, centerButton;

#pragma mark -
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Create the location manager object 
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;

    // Once configured, the location manager must be "started".
    [locationManager startUpdatingLocation];
	
	// Create the ReverseGeocoder object
	reverseGeocoder = [[ReverseGeocoder alloc] initWithMapView:mapView];
}

/*
 * To ensure that you properly relinquish ownership of outlets,
 * in your custom view controller class you can implement viewDidUnload
 * to invoke your accessor methods to set outlets to nil.
 */
- (void)viewDidUnload
{	
	self.mapView = nil;
	self.centerButton = nil;

	[super viewDidUnload];
}

/*
 * Because of a detail of the implementation of dealloc in UIViewController,
 * you should also set outlet variables to nil in dealloc
 */
- (void)dealloc
{	
	mapView.delegate = nil;
	[mapView release], mapView = nil;
	[centerButton release], centerButton = nil;
	locationManager.delegate = nil;
    [locationManager release];
	[reverseGeocoder release];

    [super dealloc];
}

#pragma mark -
#pragma mark Button actions

- (IBAction)centerAction:(id)sender
{
	[mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
}

// Display the FlipsideViewController
- (IBAction)showInfo:(id)sender
{
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark UISearchBarDelegate protocol methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar becomeFirstResponder];
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	
	NSArray *annotations = [self getNearbyAddresses:searchBar.text];
	
	[mapView addAnnotations:annotations];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{	
	static NSString *defaultPinID = @"org.snapfresh.pin";
	
	MKAnnotationView *annotationView = nil;
	
	// If it's the user location, just return nil.
    if (![annotation isKindOfClass:[MKUserLocation class]])
	{
		// Try to dequeue an existing annotation view first
		annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		
		if (!annotationView)
		{
			// If an existing annotation view was not available, create one
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
			annotationView.canShowCallout = YES;
		}
		else
		{
			annotationView.annotation = annotation;
		}
	}
	
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods - Available in iOS 2.0 and later.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)userLocation fromLocation:(CLLocation *)oldLocation
{
	if ((userLocation.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) && (userLocation.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
		
		[centerButton setEnabled:YES];
		
		[reverseGeocoder updateGeoCoderWithLocation:userLocation];
	}
	else
	{
		[centerButton setEnabled:NO];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[centerButton setEnabled:NO];
}

#pragma mark -
#pragma mark FlipsideViewControllerDelegate method
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Get nearby addresses

// Returns an array of MKPointAnnotation objects for now
- (NSArray *)getNearbyAddresses:(NSString *)address
{	
	NSArray *addresses = nil;
	
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	if ([internetReach currentReachabilityStatus] != NotReachable)
	{
		// Create the URL
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://snapfresh.org/retailers/nearaddy.text/?address=%@", 
										   [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		
		// Show network activity indicator
		UIApplication *app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = YES;
		
		NSStringEncoding encoding;
		NSError *error;
		
		// Read data from the URL.
		NSString *returnString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
		
		addresses = [ResponseParser parseResponse:returnString];

		// Hide network activity indicator
		app.networkActivityIndicatorVisible = NO;
	}
	
	return addresses;
}

@end