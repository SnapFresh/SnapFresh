//
//  DetailViewController.m
//  SnapFresh
//
//  Created by Marco Abundo on 1/18/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import "DetailViewController.h"
#import "SnapRetailer.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)fetchCoordinateForAnnotation:(id <MKAnnotation>)annotation;
@end

@implementation DetailViewController

@synthesize mapView;
@synthesize masterPopoverController;
@synthesize delegate;

// The SnapFresh URI
static NSString *kSnapFreshURI = @"http://snapfresh.org/retailers/nearaddy.text/?address=%@";

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
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Parse the Snapfresh response

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
            [self fetchCoordinateForAnnotation:retailer];
		}
	}
}

#pragma mark - Update the visible map rectangle

- (void)updateVisibleMapRect
{
    MKMapRect zoomRect = MKMapRectNull;

    for (id <MKAnnotation> annotation in mapView.annotations)
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

#pragma mark - Set annotations for nearby addresses

- (void)setAnnotationsForAddressString:(NSString *)address
{
	// First, remove non MKUserLocation annotations from the map
	NSArray *oldAnnotations = [mapView.annotations filteredArrayUsingPredicate:
                               [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [MKUserLocation class]]];
	
	[mapView removeAnnotations:oldAnnotations];
    
    // Create the SnapFresh web service URI with address as a parameter
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kSnapFreshURI, 
                                       [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    // Submit a block for asynchronous execution to our dispatchQueue and return immediately.
    dispatch_async(dispatchQueue, ^{
        // Start the network activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSStringEncoding encoding;
        NSError *error;
        
        // Returns a string created by reading data from the SnapFresh web service
        NSString *addressesString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
        
        // Parse the SnapFresh response string
        [self parseResponse:addressesString];
    });
}

#pragma mark - Fetch the coordinate for an annotation

- (void)fetchCoordinateForAnnotation:(id <MKAnnotation>)annotation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    NSString *address = annotation.subtitle;
    
	// Fetch the geocode for the street address
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = [placemarks objectAtIndex:0];
         CLLocationCoordinate2D coordinate = topResult.location.coordinate;
         
         // Set the annotation's coordinate
         [annotation setCoordinate:coordinate];
         
         // Dispatch a block that gets queued up in the main_queue
         // to add the annotation to the mapView.
         dispatch_async(dispatch_get_main_queue(),^ {
             // Stop the network activity indicator
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

             [mapView addAnnotation:annotation];
         });
     }];
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
