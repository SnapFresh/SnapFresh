/*
 * Copyright 2012 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DetailViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SnapRetailer.h"

@interface DetailViewController () // Class extension
@property (nonatomic, weak) IBOutlet UIBarButtonItem *centerButton;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;

- (void)setAnnotationsForAddressString:(NSString *)address;
- (void)fetchCoordinateForRetailer:(SnapRetailer *)retailer;
- (void)parseResponse:(NSString *)response;
- (void)updateVisibleMapRect;
@end

#pragma mark -

@implementation DetailViewController

@synthesize mapView;
@synthesize centerButton;
@synthesize masterPopoverController;
@synthesize delegate;
@synthesize retailers;

// The SnapFresh URI
static NSString *kSnapFreshURI = @"http://snapfresh.org/retailers/nearaddy.text/?address=%@";

#pragma mark - Memory management

- (void)dealloc
{
	mapView.delegate = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a new dispatch queue to which blocks can be submitted.
    dispatchQueue = dispatch_queue_create("com.shrtlist.snapfresh.dispatchQueue", NULL);
}

- (void)viewDidUnload
{
    // Release the dispatch queue
    dispatch_release(dispatchQueue);
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - Target action methods

- (IBAction)centerAction:(id)sender
{
    CLLocationCoordinate2D coordinate = mapView.userLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *address = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
        
        [self setAnnotationsForAddressString:address];
    }
}

- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if ([segmentedControl selectedSegmentIndex] == 0)
	{
		[mapView setMapType:MKMapTypeStandard];
	}
	else if ([segmentedControl selectedSegmentIndex] == 1)
	{
		[mapView setMapType:MKMapTypeSatellite];
	}
	else if ([segmentedControl selectedSegmentIndex] == 2)
	{
		[mapView setMapType:MKMapTypeHybrid];
	}
}

#pragma mark - Parse the Snapfresh response

- (void)setAnnotationsForAddressString:(NSString *)address
{
	// Remove retailers from the map
	[mapView removeAnnotations:[self retailers]];
    
    // Create the SnapFresh web service URI with address as a parameter
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kSnapFreshURI, 
                                       [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    // Submit a block for asynchronous execution to our dispatchQueue and return immediately.
    dispatch_async(dispatchQueue, ^{
        
        NSStringEncoding encoding;
        NSError *error;
        
        // Returns a string created by reading data from the SnapFresh web service
        NSString *addressesString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];

        // Parse the SnapFresh response string
        [self parseResponse:addressesString];
    });
}

- (void)parseResponse:(NSString *)response
{	
	if (response)
	{
		// SnapFresh retailer names and addresses are contained in the response string
		NSArray *retailersArray = [response componentsSeparatedByString:@"\n\n"];
		
		for (NSString *retailerString in retailersArray)
		{
			// Separate the retailerString into its components
			NSArray *retailerComponents = [retailerString componentsSeparatedByString:@"\n"];
            NSString *name = [retailerComponents objectAtIndex:0]; // Store name
            NSString *address = [retailerComponents objectAtIndex:1]; // Address
            
            // Initialize the SnapRetailer model object with a name and address
            SnapRetailer *retailer = [[SnapRetailer alloc] initWithName:name andAddress:address];
            
            // Set its coordinate in this method, and add it to the map.
            [self fetchCoordinateForRetailer:retailer];
		}
	}
}

// Fetch the coordinate for a SnapFresh retailer
- (void)fetchCoordinateForRetailer:(SnapRetailer *)retailer
{
    // Start the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
	// Fetch the geocode for the retailer's street address
    // Completion handler block will be executed on the main thread.
    [geocoder geocodeAddressString:retailer.address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // Stop the network activity indicator
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         if (error)
         {
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = [placemarks objectAtIndex:0];
         CLLocationCoordinate2D coordinate = topResult.location.coordinate;
         
         [retailer setCoordinate:coordinate];
         
         [mapView addAnnotation:retailer];
         
         // Manually fire the mapView delegate method
         [mapView.delegate mapView:mapView didAddAnnotationViews:[self retailers]];
     }];
}

#pragma mark - Update the visible map rectangle

- (void)updateVisibleMapRect
{
    MKMapRect zoomRect = MKMapRectNull;

    for (id <MKAnnotation> annotation in [self retailers])
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);

        if (MKMapRectIsNull(zoomRect))
        {
            zoomRect = pointRect;
        }
        else
        {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }

    [mapView setVisibleMapRect:zoomRect animated:YES];
}

- (NSArray *)retailers
{
    // Return SnapRetailer annotations from the map
	return [mapView.annotations filteredArrayUsingPredicate:
                               [NSPredicate predicateWithFormat:@"(self isKindOfClass:%@)", [SnapRetailer class]]];
}

#pragma mark - UISplitViewControllerDelegate conformance

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"List", @"List");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];

    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];

    self.masterPopoverController = nil;
}

#pragma mark - MKMapViewDelegate conformance

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [self updateVisibleMapRect];
    
    // Notify our delegate that the map has new annotations.
    [delegate annotationsDidLoad:self];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	static BOOL didSetRegion = NO;

    [centerButton setEnabled:YES];

    // Set the map's region if it's not set
    if (didSetRegion == NO)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        // Fetch the geocode for the retailer's street address
        // Completion handler block will be executed on the main thread.
        [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }

             // Get the top result returned by the geocoder
             CLPlacemark *topResult = [placemarks objectAtIndex:0];
             
             NSString *address = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);
             
             [self setAnnotationsForAddressString:address];
             
             didSetRegion = YES;
         }];
    }
	else
	{
		[centerButton setEnabled:NO];
	}
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	[centerButton setEnabled:NO];
}

#pragma mark - UISearchBarDelegate conformance

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Dismiss the keyboard if it's currently open
    if ([searchBar isFirstResponder])
    {
        [searchBar resignFirstResponder];
    }

    [self setAnnotationsForAddressString:searchBar.text];
}

@end