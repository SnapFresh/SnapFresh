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
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) SnapRetailer *retailer;
// an ad hoc string to hold an XML element value
@property (nonatomic, strong) NSMutableString *currentElementValue;

- (void)setAnnotationsForAddressString:(NSString *)address;
@end

#pragma mark -

@implementation DetailViewController

@synthesize mapView;
@synthesize centerButton;
@synthesize searchBar = _searchBar;
@synthesize masterPopoverController;
@synthesize delegate;
// Synthesize a read-only property named "retailers", but wire it to the member variable named "_retailers".
@synthesize retailers = _retailers;
@synthesize retailer;
@synthesize currentElementValue;

// The SnapFresh URI
static NSString *kSnapFreshURI = @"http://snapfresh.org/retailers/nearaddy.xml/?address=%@";

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

#pragma mark - Implement getter

- (NSArray *)retailers
{
    return [_retailers copy];
}

#pragma mark - Target action methods

- (IBAction)centerAction:(id)sender
{
    CLLocationCoordinate2D coordinate = mapView.userLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *address = mapView.userLocation.subtitle;
        
        self.searchBar.text = address;
        
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
        
        // Initialize the parser with SnapFresh XML content
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        parser.delegate = self;
        
        // Create a block that gets queued up in the main_queue, a default serial queue,
        // which parses the XML content
        dispatch_async(dispatch_get_main_queue(), ^{
            // Parse the SnapFresh XML response
            [parser parse];
            
            [mapView addAnnotations:[self retailers]];
            
            // Manually fire the mapView delegate method
            [mapView.delegate mapView:mapView didAddAnnotationViews:self.retailers];
        });
    });
}

#pragma mark - NSXMLParserDelegate conformance

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"retailers"])
    {
        //self.retailers = [NSMutableArray array];
        _retailers = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"retailer"])
    {
        self.retailer = [[SnapRetailer alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Skip newline
    if (![string hasPrefix:@"\n"])
    {
        if (!currentElementValue)
        {
            // Init the ad hoc string with the value     
            self.currentElementValue = [[NSMutableString alloc] initWithString:string];
        }
        else
        {
            // Append value to the ad hoc string    
            [currentElementValue appendString:string];
        }
        NSLog(@"Processing value for : %@", string);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{    
    if ([elementName isEqualToString:@"retailers"])
    {
        // We reached the end of the XML document
        return;
    }
    
    if ([elementName isEqualToString:@"retailer"])
    {
        // We are done with retailer entry
        [_retailers addObject:retailer];
    }
    else
    {
        // The parser hit one of the element values. 
        // This syntax is possible because Retailer object 
        // property names match the XML user element names
        @try
        {
            [retailer setValue:currentElementValue forKey:elementName];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@", exception);
        }
    }

    currentElementValue = nil;
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

#pragma mark - InAppSettingsKit

- (IBAction)showInfoView:(id)sender
{
    IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
    [appSettingsViewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    appSettingsViewController.showDoneButton = YES;
    appSettingsViewController.delegate = self;
    appSettingsViewController.title = NSLocalizedString(@"About", @"About");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:navController animated:YES];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UISplitViewControllerDelegate conformance

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Retailers", @"Retailers");
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
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    // Reverse geocode the user's location
    // Completion handler block will be executed on the main thread.
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"Reverse geocode failed with error: %@", error);
             [centerButton setEnabled:NO];
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = [placemarks objectAtIndex:0];
         
         NSString *address = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);
         userLocation.subtitle = address;
         
         [centerButton setEnabled:YES];
         
         // Set the map's region if it's not set
         if (didSetRegion == NO)
         {
             [self setAnnotationsForAddressString:address];
             
             didSetRegion = YES;
         }
     }];
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