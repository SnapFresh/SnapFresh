//
//  MainViewController
//

#include <math.h>
#import "MainViewController.h"
#import "ForwardGeocoder.h"
#import "ResponseParser.h"
#import "Reachability.h"

@interface MainViewController ()

- (void)setAnnotationsForCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)centerMapAroundAnnotations;

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
	[self setAnnotationsForCoordinate:locationManager.location.coordinate];
	[self centerMapAroundAnnotations];
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
	
	centerCoordinate = [ForwardGeocoder fetchGeocodeForAddress:searchBar.text];
	
	[reverseGeocoder updateGeoCoderWithCoordinate:centerCoordinate];
	
	[self setAnnotationsForCoordinate:centerCoordinate];
	
	[self centerMapAroundAnnotations];
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
	
	MKPinAnnotationView *annotationView = nil;
	
	// If it's the user location, just return nil.
    if (![annotation isKindOfClass:[MKUserLocation class]])
	{
		// Try to dequeue an existing annotation view first
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		
		if (!annotationView)
		{
			// If an existing annotation view was not available, create one
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
			annotationView.canShowCallout = YES;
			annotationView.animatesDrop = YES;
			annotationView.selected = YES;
		}
		else
		{
			annotationView.annotation = annotation;
		}
	}
	
    return annotationView;
}

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods - Available in iOS 2.0 and later.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)userLocation fromLocation:(CLLocation *)oldLocation
{
	static BOOL didSetRegion = NO;
	
	if ((userLocation.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) && (userLocation.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
		
		[centerButton setEnabled:YES];
		centerCoordinate = userLocation.coordinate;
		
		if (!didSetRegion)
		{
			[self setAnnotationsForCoordinate:userLocation.coordinate];
			[self centerMapAroundAnnotations];
			
			didSetRegion = YES;
		}
		
		[reverseGeocoder updateGeoCoderWithCoordinate:userLocation.coordinate];
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

- (void)setAnnotationsForCoordinate:(CLLocationCoordinate2D)coordinate
{	
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	if ([internetReach currentReachabilityStatus] != NotReachable)
	{
		NSString *stringCoordinate = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
		
		// Create the URL
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://snapfresh.org/retailers/nearaddy.text/?address=%@", 
										   [stringCoordinate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		
		// Show network activity indicator
		UIApplication *app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = YES;
		
		NSStringEncoding encoding;
		NSError *error;
		
		// Get the return string containing nearby addresses
		NSString *returnString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];

		// Hide network activity indicator
		app.networkActivityIndicatorVisible = NO;
		
		// Filter for old annotations
		NSArray *oldAnnotations = [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]];

		// Remove old annotations from the map
		[mapView removeAnnotations:oldAnnotations];

		// Parse annotations from the return string
		NSArray *annotations = [ResponseParser parse:returnString];
		
		// Add annotations to the map
		[mapView addAnnotations:annotations];
	}
}

- (void)centerMapAroundAnnotations
{
    // if we have no annotations we can skip all of this
    if ( [[mapView annotations] count] == 0 )
        return;
	
    // then run through each annotation in the list to find the
    // minimum and maximum latitude and longitude values
    CLLocationCoordinate2D min;
    CLLocationCoordinate2D max; 
    BOOL minMaxInitialized = NO;
    NSUInteger numberOfValidAnnotations = 0;
	
    for (id <MKAnnotation> annotation in mapView.annotations)
    {
        // only use annotations that are of our own custom type
        // in the event that the user is browsing from a location far away
        // you can omit this if you want the user's location to be included in the region 
        if ( [annotation isKindOfClass: [MKPointAnnotation class]] )
        {
			// if we haven't grabbed the first good value, do so now
			if ( !minMaxInitialized )
			{
				min = annotation.coordinate;
				max = annotation.coordinate;
				minMaxInitialized = YES;
			}
			else // otherwise compare with the current value
			{
				min.latitude = MIN( min.latitude, annotation.coordinate.latitude );
				min.longitude = MIN( min.longitude, annotation.coordinate.longitude );
				
				max.latitude = MAX( max.latitude, annotation.coordinate.latitude );
				max.longitude = MAX( max.longitude, annotation.coordinate.longitude );
			}
			++numberOfValidAnnotations;
        }
    }
	
    // If we don't have any valid annotations we can leave now,
    // this will happen in the event that there is only the user location
    if ( numberOfValidAnnotations == 0 )
        return;
	
    // Now that we have a min and max lat/lon create locations for the
    // three points in a right triangle
    CLLocation* locSouthWest = [[CLLocation alloc] initWithLatitude:min.latitude longitude:min.longitude];
    CLLocation* locSouthEast = [[CLLocation alloc] initWithLatitude:min.latitude longitude:max.longitude];
    CLLocation* locNorthEast = [[CLLocation alloc] initWithLatitude:max.latitude longitude:max.longitude];
	
    // Use the locations that we just created to calculate the distance
    // between each of the points in meters.
	CLLocationDistance latMeters = [locSouthEast getDistanceFrom:locNorthEast];
    CLLocationDistance lonMeters = [locSouthWest getDistanceFrom:locNorthEast];
	
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, latMeters, lonMeters);
	
    MKCoordinateRegion fitRegion = [mapView regionThatFits:region];
    [mapView setRegion:fitRegion animated:YES];
	
    // Clean up
    [locSouthWest release];
    [locSouthEast release];
    [locNorthEast release];
}

@end