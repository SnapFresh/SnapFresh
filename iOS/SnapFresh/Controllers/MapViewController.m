/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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
#import "SVProgressHUD.h"
#import "MDACClasses.h"
#import "WildcardGestureRecognizer.h"
#import "Constants.h"
#import "MapUtils.h"

@interface MapViewController () // Class extension
@property (nonatomic, weak) IBOutlet UIView *toggleView; // Contains map and list views
@property (nonatomic, weak) IBOutlet UIView *mapContainerView; // For iPhone version, contains map view
@property (nonatomic, weak) IBOutlet UIView *listContainerView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *centerButton;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *segmentWrapper;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *listBarButtonItem;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet UIView *redoSearchView;
@property (nonatomic, weak) IBOutlet UIButton *redoSearchButton;
@end

#pragma mark -

@implementation MapViewController
{
    MKUserTrackingBarButtonItem *trackingButton;
    UIPopoverController *masterPopoverController;
    ListViewController *listViewController;
    RequestController *requestController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    }

    requestController = [[RequestController alloc] init];
    requestController.delegate = self;
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesEndedCallback = ^(NSSet * touches, UIEvent * event)
    {
        if (![SVProgressHUD isVisible])
        {
            self.redoSearchView.hidden = NO;
        }
    };
    [self.mapView addGestureRecognizer:tapInterceptor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        listViewController = (self.childViewControllers)[0];
        listViewController.mapViewController = self;
        self.delegate = listViewController;
    }

    [self configureViews];
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
    self.redoSearchView.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else
    {
        return YES;
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    // Nil out delegates
	self.mapView.delegate = nil;
    self.searchBar.delegate = nil;
    requestController.delegate = nil;
}

#pragma mark - UI methods

- (void)configureViews
{
    [self.segmentWrapper setCustomView:self.mapTypeSegmentedControl];
    
    [self localizeView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        [self configureTrackingButton];
    }
}

- (void)localizeView
{
    NSString *standard = NSLocalizedString(@"Standard", @"Standard");
    NSString *satellite = NSLocalizedString(@"Satellite", @"Satellite");
    NSString *hybrid = NSLocalizedString(@"Hybrid", @"Hybrid");
    
    [self.mapTypeSegmentedControl setTitle:standard forSegmentAtIndex:MKMapTypeStandard];
    [self.mapTypeSegmentedControl setTitle:satellite forSegmentAtIndex:MKMapTypeSatellite];
    [self.mapTypeSegmentedControl setTitle:hybrid forSegmentAtIndex:MKMapTypeHybrid];

    NSString *title = NSLocalizedString(@"Redo search in this area", @"Redo search in this area");
    [self.redoSearchButton setTitle:title forState: UIControlStateNormal];
    self.searchBar.placeholder = NSLocalizedString(@"Enter US address or ZIP code", @"Enter US address or ZIP code");
}

- (void)configureTrackingButton
{
    trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];

    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
    [items insertObject:trackingButton atIndex:0];
    self.toolbarItems = items;
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
                    animations:^{ self.listContainerView.hidden = NO; self.mapContainerView.hidden = YES; self.redoSearchView.hidden = YES; }
                    completion:^(BOOL finished) { self.listBarButtonItem.image = [UIImage imageNamed:kMapImageName]; }];
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
                    animations:^{ self.listContainerView.hidden = YES; self.mapContainerView.hidden = NO; }
                    completion:^(BOOL finished) { self.listBarButtonItem.image = [UIImage imageNamed:kListImageName]; }];
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
    
    self.redoSearchView.hidden = YES;

    CLLocationCoordinate2D coordinate = self.mapView.userLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *address = self.mapView.userLocation.subtitle;
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
            [self.mapView setMapType:MKMapTypeStandard];
            break;
        case MKMapTypeSatellite:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        case MKMapTypeHybrid:
            [self.mapView setMapType:MKMapTypeHybrid];
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
    
    self.redoSearchView.hidden = YES;
    
    NSString *status = NSLocalizedString(@"Finding search address", @"Finding search address");
    [SVProgressHUD showWithStatus:status];

    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
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
         CLPlacemark *topResult = placemarks[0];
         
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
         [self.mapView addAnnotation:searchAnnotation];
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

    self.redoSearchView.hidden = YES;
}

- (IBAction)toggleListView
{    
    if (self.listContainerView.hidden)
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
    aboutController.showsAttributions = NO;
    aboutController.title = NSLocalizedString(@"About", @"About");
    
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

    [self presentViewController:aboutController animated:YES completion:nil];
}

#pragma mark - Map utility methods

- (void)clearMapAnnotations
{
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [MKUserLocation class]]];
    
    [self.mapView removeAnnotations:annotations];
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
        CLPlacemark *topResult = placemarks[0];
        
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
        
        [self.mapView addAnnotation:annotation];
    }];
}

- (void)setAnnotationsForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *status = NSLocalizedString(@"Finding SNAP retailers", @"Finding SNAP retailers");
    [SVProgressHUD showWithStatus:status];

    [self clearMapAnnotations];

    [requestController sendRequestForCoordinate:coordinate];
}

- (void)didSelectRetailer:(SnapRetailer *)retailer
{
    [self.mapView setCenterCoordinate:retailer.coordinate animated:NO];
    [self.mapView selectAnnotation:retailer animated:NO];
    [self toggleListView];
}

#pragma mark - Update the visible map rectangle

- (void)updateVisibleMapRect
{
    NSArray *annotations = self.mapView.annotations;
    
    // Get non-SnapRetailer annotations
    NSArray *otherAnnotations = [annotations filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [SnapRetailer class]]];
    
    // Check if both search annotation and MKUserLocation are on the map
    if (otherAnnotations.count > 1)
    {
        // If so, filter out MKUserLocation
        annotations = [self.mapView.annotations filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)", [MKUserLocation class]]];
    }
    
    MKMapRect zoomRect = [MapUtils regionToFitMapAnnotations:annotations];
    
    // Add some edge padding
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        zoomRect = [self.mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(kEdgeInsetPad, kEdgeInsetPad, kEdgeInsetPad, kEdgeInsetPad)];
    }
    else
    {
        zoomRect = [self.mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(kEdgeInsetPhone, kEdgeInsetPhone, kEdgeInsetPhone, kEdgeInsetPhone)];
    }
    
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

#pragma mark - RequestControllerDelegate

- (void)snapRetailersDidLoad:(NSArray *)snapRetailers
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    [SVProgressHUD dismiss];

    if (snapRetailers > 0)
    {
        [self.mapView addAnnotations:snapRetailers];
        
        [self updateVisibleMapRect];
        
        // Select nearest retailer
        SnapRetailer *nearestRetailer = snapRetailers[0];
        [self.mapView selectAnnotation:nearestRetailer animated:YES];
        
        // Notify our delegate that the map has new annotations.
        [self.delegate annotationsDidLoad:snapRetailers];
    }
}

- (void)snapRetailersDidNotLoadWithError:(NSError *)error
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

#pragma mark - UISplitViewControllerDelegate protocol conformance

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Retailers", @"Retailers");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];

    masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
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
            annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:retailerPinID];
            
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
            annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:searchPinID];
            
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
             [self.centerButton setEnabled:NO];
             return;
         }
         
         // Get the top result returned by the geocoder
         CLPlacemark *topResult = placemarks[0];
         
         NSString *address = ABCreateStringWithAddressDictionary(topResult.addressDictionary, NO);
         userLocation.subtitle = address;
         
         [self.centerButton setEnabled:YES];
         
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
	[self.centerButton setEnabled:NO];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    self.redoSearchView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id<MKAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[SnapRetailer class]])
    {
        SnapRetailer *retailer = (SnapRetailer *)annotation;

        NSString *className = NSStringFromClass([self class]);
        
        [[GANTracker sharedTracker] trackEvent:className
                                        action:@"didSelectAnnotationView"
                                         label:retailer.title
                                         value:-1
                                     withError:nil];
    }
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

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone)
    {
        [self centerAction:nil];
    }
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
        id <MKAnnotation> annotation = [self.mapView selectedAnnotations][0];
        
        SnapRetailer *retailer = (SnapRetailer *)annotation;
        
        [MapUtils openMapWithDestination:retailer];
    }
}

@end