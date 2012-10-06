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

#import "MapViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SnapRetailer.h"
#import "SVProgressHUD.h"
#import "MDACClasses.h"
#import "WildcardGestureRecognizer.h"
#import "Constants.h"
#import "MapUtils.h"

@interface MapViewController () // Class extension
@property (nonatomic, weak) IBOutlet UIView *toggleView; // Contains map and list views
@property (nonatomic, weak) IBOutlet UIView *mapContainerView; // For iPhone version, contains map view
@property (nonatomic, weak) IBOutlet UITableView *listView; // For iPhone version
@property (nonatomic, weak) IBOutlet UIBarButtonItem *centerButton;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *segmentWrapper;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *listBarButtonItem;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet UIView *redoSearchView;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@end

#pragma mark -

@implementation MapViewController

@synthesize toggleView;
@synthesize mapContainerView;
@synthesize mapView;
@synthesize listView;
@synthesize centerButton;
@synthesize searchBar = _searchBar;
@synthesize segmentWrapper;
@synthesize listBarButtonItem;
@synthesize mapTypeSegmentedControl;
@synthesize redoSearchView;
@synthesize masterPopoverController;
@synthesize delegate;
@synthesize retailers;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesEndedCallback = ^(NSSet * touches, UIEvent * event)
    {
        if (![SVProgressHUD isVisible])
        {
            redoSearchView.hidden = NO;
        }
    };
    [mapView addGestureRecognizer:tapInterceptor];
    
    [segmentWrapper setCustomView:mapTypeSegmentedControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    redoSearchView.hidden = YES;
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

#pragma mark - Memory management

- (void)dealloc
{
	self.mapView.delegate = nil;
    self.searchBar.delegate = nil;
}

#pragma mark - Target action methods

- (IBAction)centerAction:(id)sender
{
    redoSearchView.hidden = YES;

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
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case MKMapTypeStandard:
            [mapView setMapType:MKMapTypeStandard];
            break;
        case MKMapTypeSatellite:
            [mapView setMapType:MKMapTypeSatellite];
            break;
        case MKMapTypeHybrid:
            [mapView setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

- (IBAction)redoSearchTapped
{
    redoSearchView.hidden = YES;
    
    [SVProgressHUD showWithStatus:@"Finding search address..."];

    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude 
                                                      longitude:center.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             [SVProgressHUD showErrorWithStatus:@"We couldn't find your search address."];
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = [placemarks objectAtIndex:0];
         
         NSString *searchAddress = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);

         self.searchBar.text = searchAddress;
         [self setAnnotationsForAddressString:searchAddress];

         // Create an annotation from the placemark
         MKPointAnnotation *searchAnnotation = [[MKPointAnnotation alloc] init];
         searchAnnotation.title = @"Search address";
         searchAnnotation.subtitle = searchAddress;
         searchAnnotation.coordinate = topResult.location.coordinate;
         [mapView addAnnotation:searchAnnotation];
     }];
}

- (IBAction)dismissButtonTapped
{
    redoSearchView.hidden = YES;
}

- (IBAction)toggleListView
{
    if (listView.hidden)
    {
        [UIView transitionWithView:self.toggleView
                          duration:kAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ listView.hidden = NO; mapContainerView.hidden = YES; redoSearchView.hidden = YES; }
                        completion:^(BOOL finished) { listBarButtonItem.title = @"Map"; }];
    }
    else
    {
        [UIView transitionWithView:self.toggleView
                          duration:kAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{ listView.hidden = YES; mapContainerView.hidden = NO; }
                        completion:^(BOOL finished) { listBarButtonItem.title = @" List"; }];
    }
}

- (IBAction)showInfoView:(id)sender
{
    [SVProgressHUD dismiss];

    MDAboutController *aboutController = [[MDAboutController alloc] initWithStyle:[MDACMochiDevStyle style]];
    [aboutController removeLastCredit];    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        aboutController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        aboutController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else
    {
        aboutController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        aboutController.modalPresentationStyle = UIModalPresentationFullScreen;
    }

    [self presentModalViewController:aboutController animated:YES];
}

#pragma mark - Map utility methods

- (void)clearMapAnnotations
{
    NSArray *annotations = [mapView.annotations filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [MKUserLocation class]]];
    
    [mapView removeAnnotations:annotations];
}

- (void)setSearchBarAnnotation:(NSString *)text
{
    [SVProgressHUD showWithStatus:@"Finding search address"];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"Invalid search address"];
            self.searchBar.text = nil;
            NSLog(@"Forward geocode failed with error: %@", error);
            return;
        }
        
        // Get the top result returned by the geocoder
        CLPlacemark *topResult = [placemarks objectAtIndex:0];
        
        NSString *searchAddress = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);
        
        // Update the searchBar text
        self.searchBar.text = searchAddress;
        
        [self setAnnotationsForAddressString:searchAddress];
        
        // Create an annotation from the placemark
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = @"Search address";
        annotation.subtitle = searchAddress;
        annotation.coordinate = topResult.location.coordinate;
        
        [mapView addAnnotation:annotation];
    }];
}

#pragma mark - Send request

- (void)sendRequest:(NSString *)address
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    NSString *resourcePath = [NSString stringWithFormat:@"%@?address=%@", kSnapFreshEndpoint, address];
    RKRequest *request = [[RKClient sharedClient] requestWithResourcePath:resourcePath];
    [request setDelegate:self];
    [request send];
}

#pragma mark - RKRequestDelegate protocol conformance

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    [self parseJSONResponse:response.body];
    
    [SVProgressHUD dismiss];
    
    if (self.retailers.count > 0)
    {
        [mapView addAnnotations:self.retailers];
        
        [self updateVisibleMapRect];
        
        // Select nearest retailer
        SnapRetailer *nearestRetailer = [self.retailers objectAtIndex:0];
        [mapView selectAnnotation:nearestRetailer animated:YES];
        
        [listView reloadData];
        
        // Notify our delegate that the map has new annotations.
        [delegate annotationsDidLoad:self];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    [SVProgressHUD showErrorWithStatus:error.description];
}

#pragma mark - Parse the Snapfresh JSON response

- (void)parseJSONResponse:(NSData *)data
{
    NSError *error;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    // Get the JSON array of retailers
    NSArray *retailersJSON = [jsonResponse valueForKey:@"retailers"];
    
    NSMutableArray *_retailers = [NSMutableArray array];
    
    for (NSDictionary *jsonDictionary in retailersJSON)
    {
        // Get the JSON dictionary of a retailer
        NSDictionary *retailerDictionary = [jsonDictionary objectForKey:@"retailer"];
        SnapRetailer *retailer = [[SnapRetailer alloc] initWithDictionary:retailerDictionary];
        [_retailers addObject:retailer];
    }
    
    self.retailers = [NSArray arrayWithArray:_retailers];
}

- (void)setAnnotationsForAddressString:(NSString *)address
{
    [SVProgressHUD showWithStatus:@"Finding SNAP retailers..."];

    [self clearMapAnnotations];
    
    [self sendRequest:address];
}

#pragma mark - Update the visible map rectangle

- (void)updateVisibleMapRect
{
    NSArray *annotations = mapView.annotations;
    
    // Get non-SnapRetailer annotations
    NSArray *otherAnnotations = [annotations filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [SnapRetailer class]]];
    
    // Check if both search annotation and MKUserLocation are on the map
    if (otherAnnotations.count > 1)
    {
        // If so, filter out MKUserLocation
        annotations = [mapView.annotations filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [MKUserLocation class]]];
    }
    
    MKMapRect zoomRect = [MapUtils regionToFitMapAnnotations:annotations];
    
    // Add some padding for iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        zoomRect = [mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(kEdgeInset, kEdgeInset, kEdgeInset, kEdgeInset)];
    }
    
    [mapView setVisibleMapRect:zoomRect animated:YES];
}

#pragma mark - UISplitViewControllerDelegate protocol conformance

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

#pragma mark - MKMapViewDelegate protocol conformance

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *retailerPinID = @"com.shrtlist.retailerPin";
    static NSString *searchPinID = @"com.shrtlist.searchPin";
	
	MKPinAnnotationView *annotationView = nil;
	
	// If it's the user location, just return nil.
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        if ([annotation isKindOfClass:[SnapRetailer class]])
        {
            // Try to dequeue an existing annotation view first
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:retailerPinID];
            
            if (!annotationView)
            {
                // If an existing annotation view was not available, create one
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:retailerPinID];
                annotationView.canShowCallout = YES;
                annotationView.pinColor = MKPinAnnotationColorRed;
                annotationView.animatesDrop = YES;

                // Add Detail Disclosure button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                button.showsTouchWhenHighlighted = YES;
                annotationView.rightCalloutAccessoryView = button;
                
                UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap.png"]];
                annotationView.leftCalloutAccessoryView = sfIconView;
            }
            else
            {
                annotationView.annotation = annotation;
            }
        }
        else
        {
            // Try to dequeue an existing annotation view first
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:searchPinID];
            
            if (!annotationView)
            {
                // If an existing annotation view was not available, create one
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:searchPinID];
                annotationView.canShowCallout = YES;
                annotationView.pinColor = MKPinAnnotationColorGreen;
                annotationView.animatesDrop = YES;
            }
            else
            {
                annotationView.annotation = annotation;
            }
        }
	}
	
    return annotationView;
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

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    redoSearchView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Show driving directions?"
                                                        message:@"You will be taken to the Map app"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - UITableViewDataSource protocol conformance (for iPhone version)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.retailers.count;
}

// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SnapRetailer *retailer = [self.retailers objectAtIndex:indexPath.row];
    
    // Set the cell labels with SNAP retailer info
    cell.textLabel.text = retailer.name;
    cell.detailTextLabel.text = retailer.address;
	
	return cell;
}

#pragma mark - UITableViewDelegate protocol conformance (for iPhone version)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SnapRetailer *retailer = [self.retailers objectAtIndex:indexPath.row];
    [mapView setCenterCoordinate:retailer.coordinate];
    [mapView selectAnnotation:retailer animated:NO];
    [self toggleListView];
}

#pragma mark - UISearchBarDelegate protocol conformance

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Dismiss the keyboard if it's currently open
    if ([searchBar isFirstResponder])
    {
        [searchBar resignFirstResponder];
        [searchBar setShowsCancelButton:NO animated:YES];
    }
    
    [self setSearchBarAnnotation:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate protocol conformance

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        id <MKAnnotation> annotation = [[self.mapView selectedAnnotations] objectAtIndex:0];
        
        SnapRetailer *retailer = (SnapRetailer *)annotation;
        
        [MapUtils openMapWithDestination:retailer];
    }
}

@end