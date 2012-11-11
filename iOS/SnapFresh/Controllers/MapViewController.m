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
#import "ListViewController.h"
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
@property (nonatomic, weak) IBOutlet UIButton *redoSearchButton;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIImage *mapImage;
@property (nonatomic, strong) UIImage *listImage;
@property (nonatomic, strong) ListViewController *listViewController;
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
@synthesize redoSearchButton;
@synthesize masterPopoverController;
@synthesize delegate;
@synthesize retailers;
@synthesize mapImage;
@synthesize listImage;
@synthesize listViewController;

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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.listViewController = [[ListViewController alloc] init];
        listViewController.tableView = listView;
        listView.delegate = self;
        self.delegate = listViewController;
    }
    
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Determine the class name of this view controller using reflection.
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackPageview:className withError:nil];
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

#pragma mark - UI methods

- (void)configureView
{
    self.mapImage = [UIImage imageNamed:kMapImageName];
    self.listImage = [UIImage imageNamed:kListImageName];

    [self.segmentWrapper setCustomView:mapTypeSegmentedControl];
    
    [self localizeView];
}

- (void)localizeView
{
    NSString *standard = NSLocalizedString(@"Standard", @"Standard");
    NSString *satellite = NSLocalizedString(@"Satellite", @"Satellite");
    NSString *hybrid = NSLocalizedString(@"Hybrid", @"Hybrid");
    
    [self.mapTypeSegmentedControl setTitle:standard forSegmentAtIndex:MKMapTypeStandard];
    [self.mapTypeSegmentedControl setTitle:satellite forSegmentAtIndex:MKMapTypeSatellite];
    [self.mapTypeSegmentedControl setTitle:hybrid forSegmentAtIndex:MKMapTypeHybrid];
    
    self.redoSearchButton.titleLabel.text = NSLocalizedString(@"Redo search in this area", @"Redo search in this area");
    self.searchBar.placeholder = NSLocalizedString(@"Enter US address or ZIP code", @"Enter US address or ZIP code");
}

- (void)showListView
{
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"showListView"
                                     label:nil
                                     value:-1
                                 withError:nil];
    
    [UIView transitionWithView:self.toggleView
                      duration:kAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ listView.hidden = NO; mapContainerView.hidden = YES; redoSearchView.hidden = YES; }
                    completion:^(BOOL finished) { listBarButtonItem.image = mapImage; }];
}

- (void)showMapView
{
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"showMapView"
                                     label:nil
                                     value:-1
                                 withError:nil];
    
    [UIView transitionWithView:self.toggleView
                      duration:kAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ listView.hidden = YES; mapContainerView.hidden = NO; }
                    completion:^(BOOL finished) { listBarButtonItem.image = listImage; }];
}

#pragma mark - Target-action methods

- (IBAction)centerAction:(id)sender
{
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"centerAction"
                                     label:nil
                                     value:-1
                                 withError:nil];
    
    redoSearchView.hidden = YES;

    CLLocationCoordinate2D coordinate = mapView.userLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *address = mapView.userLocation.subtitle;
        self.searchBar.text = address;
        [self setAnnotationsForCoordinate:coordinate];
    }
}

- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"segmentAction"
                                     label:nil
                                     value:selectedSegmentIndex
                                 withError:nil];
    
    switch (selectedSegmentIndex)
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
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"redoSearchTapped"
                                     label:nil
                                     value:-1
                                 withError:nil];
    
    redoSearchView.hidden = YES;
    
    NSString *status = NSLocalizedString(@"Finding search address", @"Finding search address");
    [SVProgressHUD showWithStatus:status];

    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude 
                                                      longitude:center.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSString *errorStatus = NSLocalizedString(@"We couldn't find your search address", @"We couldn't find your search address");
             [SVProgressHUD showErrorWithStatus:errorStatus];
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = [placemarks objectAtIndex:0];
         
         // Fix for Issue #18 - Filter out non-US search addresses
         if (![topResult.ISOcountryCode isEqualToString:@"US"])
         {
             NSString *nonUSErrorStatus = NSLocalizedString(@"Non-US search address", @"Non-US search address");
             [SVProgressHUD showErrorWithStatus:nonUSErrorStatus];
             self.searchBar.text = nil;
             return;
         }
         
         NSString *searchAddress = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);

         self.searchBar.text = searchAddress;
         [self setAnnotationsForCoordinate:topResult.location.coordinate];

         // Create an annotation from the placemark
         MKPointAnnotation *searchAnnotation = [[MKPointAnnotation alloc] init];
         searchAnnotation.title = NSLocalizedString(@"Search address", @"Search address");
         searchAnnotation.subtitle = searchAddress;
         searchAnnotation.coordinate = topResult.location.coordinate;
         [mapView addAnnotation:searchAnnotation];
     }];
}

- (IBAction)dismissButtonTapped
{
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"dismissButtonTapped"
                                     label:nil
                                     value:-1
                                 withError:nil];

    redoSearchView.hidden = YES;
}

- (IBAction)toggleListView
{    
    if (listView.hidden)
    {
        [self showListView];
    }
    else
    {
        [self showMapView];
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
    NSString *status = NSLocalizedString(@"Finding search address", @"Finding search address");
    [SVProgressHUD showWithStatus:status];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error)
        {
            NSString *errorStatus = NSLocalizedString(@"Invalid search address", @"Invalid search address");
            [SVProgressHUD showErrorWithStatus:errorStatus];
            self.searchBar.text = nil;
            NSLog(@"Forward geocode failed with error: %@", error);
            return;
        }
        
        // Get the top result returned by the geocoder
        CLPlacemark *topResult = [placemarks objectAtIndex:0];
        
        // Fix for Issue #18 - Filter out non-US search addresses
        if (![topResult.ISOcountryCode isEqualToString:@"US"])
        {
            NSString *nonUSErrorStatus = NSLocalizedString(@"Non-US search address", @"Non-US search address");
            [SVProgressHUD showErrorWithStatus:nonUSErrorStatus];
            self.searchBar.text = nil;
            return;
        }
        
        NSString *searchAddress = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);
        
        // Update the searchBar text
        self.searchBar.text = searchAddress;
        
        [self setAnnotationsForCoordinate:topResult.location.coordinate];
        
        // Create an annotation from the placemark
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = NSLocalizedString(@"Search address", @"Search address");
        annotation.subtitle = searchAddress;
        annotation.coordinate = topResult.location.coordinate;
        
        [mapView addAnnotation:annotation];
    }];
}

#pragma mark - Send SnapFresh request

- (void)sendRequestForCoordinate:(CLLocationCoordinate2D)coordinate
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    // Set up our resource path
    NSString *address = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    NSString *resourcePath = [NSString stringWithFormat:@"%@?address=%@", kSnapFreshEndpoint, address];
    
    // Set up our request
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
        [delegate annotationsDidLoad:self.retailers];
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

- (void)setAnnotationsForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *status = NSLocalizedString(@"Finding SNAP retailers", @"Finding SNAP retailers");
    [SVProgressHUD showWithStatus:status];

    [self clearMapAnnotations];
    
    [self sendRequestForCoordinate:coordinate];
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
    
    // Add some edge padding
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        zoomRect = [mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(kEdgeInsetPad, kEdgeInsetPad, kEdgeInsetPad, kEdgeInsetPad)];
    }
    else
    {
        zoomRect = [mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(kEdgeInsetPhone, kEdgeInsetPhone, kEdgeInsetPhone, kEdgeInsetPhone)];
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
                
                UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap"]];
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
             [self setAnnotationsForCoordinate:topResult.location.coordinate];
             
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id <MKAnnotation> annotation = view.annotation;

    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"didSelectAnnotationView"
                                     label:annotation.title
                                     value:-1
                                 withError:nil];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *title = NSLocalizedString(@"Show driving directions?", @"Show driving directions?");
    NSString *message = NSLocalizedString(@"You will be taken to the Map app", @"You will be taken to the Map app");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel");
    NSString *okButtonTitle = NSLocalizedString(@"OK", @"OK");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:okButtonTitle, nil];
    [alertView show];
}

#pragma mark - UITableViewDelegate protocol conformance (for iPhone version)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SnapRetailer *retailer = [self.retailers objectAtIndex:indexPath.row];
    
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"didSelectRowAtIndexPath"
                                     label:retailer.name
                                     value:-1
                                 withError:nil];
    
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
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"searchBarSearchButtonClicked"
                                     label:searchBar.text
                                     value:-1
                                 withError:nil];
    
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
    NSString *className = NSStringFromClass([self class]);
    [[GANTracker sharedTracker] trackEvent:className
                                    action:@"searchBarCancelButtonClicked"
                                     label:nil
                                     value:-1
                                 withError:nil];

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