/*
 * Copyright 2014 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

import CoreLocation
import MapKit
import UIKit

/*!
@class MapViewController
@abstract
Presents SNAP retailers and farmers markets in a map view
*/
class MapViewController : UIViewController,
    UISearchBarDelegate,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    UIGestureRecognizerDelegate {

    @IBOutlet var toggleView: UIView? // Contains map and list views
    @IBOutlet var mapContainerView: UIView? // For iPhone version, contains map view
    @IBOutlet var listContainerView: UIView?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var searchBar: UISearchBar?
    @IBOutlet var segmentWrapper: UIBarButtonItem?
    @IBOutlet var listBarButtonItem: UIBarButtonItem?
    @IBOutlet var mapTypeSegmentedControl: UISegmentedControl?
    @IBOutlet var redoSearchView: UIView?
    @IBOutlet var redoSearchButton: UIButton?
    @IBOutlet var padToolbar: UIToolbar?
    var locationManager: CLLocationManager!

    var trackingButton: MKUserTrackingBarButtonItem?
    var requestController: RequestController?

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            navigationItem.titleView = self.searchBar
        }

        requestController = RequestController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "snapRetailersDidLoad:", name: Constants.kSNAPRetailersDidLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "snapRetailersDidNotLoadWithError:", name: Constants.kSNAPRetailersDidNotLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "farmersMarketsDidLoad:", name: Constants.kFarmersMarketsDidLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "farmersMarketsDidNotLoadWithError:", name: Constants.kFarmersMarketsDidNotLoadNotification, object: nil)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
        panRecognizer.delegate = self
        
        mapView!.addGestureRecognizer(panRecognizer)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            let listViewController = childViewControllers.first as! ListViewController
            listViewController.mapViewController = self
        }
        else {
            let navController = splitViewController!.childViewControllers.first
            let listViewController = navController!.childViewControllers.first as! ListViewController
            listViewController.mapViewController = self
        }
        
        requestLocationServicesAuthorization()

        configureViews()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        redoSearchView!.hidden = true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        }
        else {
            return UIInterfaceOrientationMask.All
        }
    }

    // MARK: Deinitialization
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        // Nil out delegates
        mapView!.delegate = nil;
        searchBar!.delegate = nil;
    }
    
    // MARK: UI methods

    func configureViews() {
        SVProgressHUD.setForegroundColor(UIColor(red: (100.0/255.0), green:(153.0/255.0), blue:(51.0/255.0), alpha:1.0))
        
        // http://stackoverflow.com/questions/19239227/uisegmentedcontrol-tint-color-isnt-drawn-correctly-on-ios-7
        mapTypeSegmentedControl?.tintColor = UIColor.clearColor()
        mapTypeSegmentedControl?.tintColor = view.tintColor
        
        segmentWrapper?.customView = mapTypeSegmentedControl
        
        localizeView()
    }

    func localizeView() {
        let standard = NSLocalizedString("Standard", comment: "Standard")
        let satellite = NSLocalizedString("Satellite", comment: "Satellite")
        let hybrid = NSLocalizedString("Hybrid", comment: "Hybrid")
        
        mapTypeSegmentedControl!.setTitle(standard, forSegmentAtIndex: 0)
        mapTypeSegmentedControl!.setTitle(satellite, forSegmentAtIndex: 1)
        mapTypeSegmentedControl!.setTitle(hybrid, forSegmentAtIndex: 2)

        let title = NSLocalizedString("Redo search in this area", comment: "Redo search in this area")
        redoSearchButton!.setTitle(title, forState: UIControlState.Normal)
        searchBar!.placeholder = NSLocalizedString("Enter US address or ZIP code", comment: "Enter US address or ZIP code")
    }

    func configureTrackingButton() {
        trackingButton = MKUserTrackingBarButtonItem(mapView: mapView)
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            var items: Array<UIBarButtonItem> = toolbarItems!
            items.insert(trackingButton!, atIndex: 0)
            setToolbarItems(items, animated: true)
        }
        else {
            var items: Array<UIBarButtonItem> = (padToolbar?.items)!
            items.insert(trackingButton!, atIndex: 0)
            padToolbar?.setItems(items, animated: true)
        }
    }

    func showListView() {
        UIView.transitionWithView(toggleView!,
                          duration: Constants.kAnimationDuration,
                           options: UIViewAnimationOptions.TransitionFlipFromLeft,
                        animations: {
                            self.listContainerView!.hidden = false
                            self.mapContainerView!.hidden = true
                            self.redoSearchView!.hidden = true
            },
            completion: { (BOOL finished) in
                self.listBarButtonItem!.image = UIImage(named: Constants.kMapImageName)
        })
    }

    func showMapView() {
        UIView.transitionWithView(toggleView!,
                          duration: Constants.kAnimationDuration,
                           options: UIViewAnimationOptions.TransitionFlipFromRight,
                        animations: {
                            self.listContainerView!.hidden = true
                            self.mapContainerView!.hidden = false
            },
            completion: { (BOOL finished) in
                self.listBarButtonItem!.image = UIImage(named: Constants.kListImageName)
        })
    }

    func centerAction() {
        redoSearchView!.hidden = true

        let coordinate = mapView!.userLocation.coordinate
        
        if CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude != 0.0) && (coordinate.longitude != 0.0) {
            let address = mapView!.userLocation.subtitle
            searchBar!.text = address
            setAnnotationsForCoordinate(coordinate)
        }
    }
    
    // MARK: Target-action methods

    @IBAction func segmentAction(sender: UISegmentedControl) {
        // The segmented control was clicked, handle it here
        let segmentedControl = sender
        
        let selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            mapView!.mapType = MKMapType.Standard
        case 1:
            mapView!.mapType = MKMapType.Satellite
        case 2:
            mapView!.mapType = MKMapType.Hybrid
            default:
                break
        }
    }

    @IBAction func redoSearchTapped(sender: UIButton) {
        redoSearchView!.hidden = true
    
        let status = NSLocalizedString("Finding search address", comment: "Finding search address")
        SVProgressHUD.showWithStatus(status)

        let center = mapView!.centerCoordinate
        let location = CLLocation(latitude: center.latitude, longitude:center.longitude)

        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if (error != nil) {
                let errorStatus = NSLocalizedString("We couldn't find your search address", comment: "We couldn't find your search address")
                SVProgressHUD.showErrorWithStatus(errorStatus)
                return
            }
            
            // Get the top result returned by the geocoder
            let topResult = placemarks?.first
            
            // Fix for Issue #18 - Filter out non-US search addresses
            if topResult?.ISOcountryCode != "US" {
                let nonUSErrorStatus = NSLocalizedString("Non-US search address", comment: "Non-US search address")
                SVProgressHUD.showErrorWithStatus(nonUSErrorStatus)
                self.searchBar!.text = nil
                return
            }
            
            let addressDictionary = topResult!.addressDictionary
             
             let formattedAddressLines = addressDictionary!["FormattedAddressLines"] as! NSArray
             
             let searchAddress = formattedAddressLines.componentsJoinedByString(", ")

             // Update the searchBar text
             self.searchBar!.text = searchAddress
             
             self.setAnnotationsForCoordinate(topResult!.location!.coordinate)

            // Create an annotation from the placemark
            let searchAnnotation = MKPointAnnotation()
            searchAnnotation.title = NSLocalizedString("Search address", comment: "Search address")
            searchAnnotation.subtitle = searchAddress
            searchAnnotation.coordinate = topResult!.location!.coordinate
            self.mapView!.addAnnotation(searchAnnotation)
         })
    }
    
    @IBAction func dismissButtonTapped(sender: UIButton) {
        redoSearchView!.hidden = true
    }

    @IBAction func toggleListView(sender: UIBarButtonItem) {
        if listContainerView!.hidden {
            showListView()
        }
        else {
            showMapView()
        }
    }
    
    func cancelButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            if !SVProgressHUD.isVisible() {
                redoSearchView!.hidden = false
            }
        }
    }

    // MARK: Map utility methods

    func clearMapAnnotations() {
        let annotations = mapView!.annotations as NSArray
        let predicate = NSPredicate(format: "!(self isKindOfClass:%@)", argumentArray: [MKUserLocation.self])
        let filteredAnnotations = annotations.filteredArrayUsingPredicate(predicate) as! [MKAnnotation]
    
        mapView!.removeAnnotations(filteredAnnotations)
    }

    func setSearchBarAnnotation(text: NSString) {
        let status = NSLocalizedString("Finding search address", comment: "Finding search address")
        SVProgressHUD.showWithStatus(status)

        CLGeocoder().geocodeAddressString(text as String, completionHandler: { (placemarks, error) in
            if (error != nil) {
                let errorStatus = NSLocalizedString("Invalid search address", comment: "Invalid search address")
                SVProgressHUD.showErrorWithStatus(errorStatus)
                self.searchBar!.text = nil
                NSLog("Forward geocode failed with error: %@", error!)
                return
            }
            
            // Get the top result returned by the geocoder
            let topResult = placemarks?.first
            
            // Fix for Issue #18 - Filter out non-US search addresses
            if topResult!.ISOcountryCode != "US" {
                let nonUSErrorStatus = NSLocalizedString("Non-US search address", comment: "Non-US search address")
                SVProgressHUD.showErrorWithStatus(nonUSErrorStatus)
                self.searchBar!.text = nil
                return
            }
            
            let addressDictionary = topResult!.addressDictionary
            
            let formattedAddressLines = addressDictionary!["FormattedAddressLines"] as! NSArray
            
            let searchAddress = formattedAddressLines.componentsJoinedByString(", ")
     
            // Update the searchBar text
            self.searchBar!.text = searchAddress
            
            self.setAnnotationsForCoordinate(topResult!.location!.coordinate)
            
            // Create an annotation from the placemark
            let annotation = MKPointAnnotation()
            annotation.title = NSLocalizedString("Search address", comment: "Search address")
            annotation.subtitle = searchAddress
            annotation.coordinate = topResult!.location!.coordinate
            
            self.mapView!.addAnnotation(annotation)
        })
    }
    
    func setAnnotationsForCoordinate(coordinate: CLLocationCoordinate2D) {
        let status = NSLocalizedString("Finding SNAP retailers", comment: "Finding SNAP retailers")
        SVProgressHUD.showWithStatus(status)

        clearMapAnnotations()

        requestController!.sendSNAPRequestForCoordinate(coordinate)

        requestController!.sendFarmersMarketRequestForCoordinate(coordinate)
    }
    
    func didSelectRetailer(retailer: MKPlacemark) {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "barButtonItemClicked:")
            toggleListView(barButtonItem)
        }
        mapView!.setCenterCoordinate(retailer.coordinate, animated: true)
        mapView!.selectAnnotation(retailer, animated: true)
    }
    
    // MARK: Update the visible map rectangle
    func updateVisibleMapRect() {
        var annotations = mapView!.annotations as NSArray
        
        // Get non-SnapRetailer annotations
        var predicate = NSPredicate(format: "!(self isKindOfClass:%@)", argumentArray: [SnapRetailer.self])
        let otherAnnotations = annotations.filteredArrayUsingPredicate(predicate)
        
        // Check if both search annotation and MKUserLocation are on the map
        if (otherAnnotations.count > 1) {
            // If so, filter out MKUserLocation
            predicate = NSPredicate(format: "!(self isKindOfClass:%@)", argumentArray: [MKUserLocation.self])
            annotations = annotations.filteredArrayUsingPredicate(predicate)
        }
        
        var zoomRect = MapUtils.regionToFitMapAnnotations(annotations as! [MKAnnotation])
        
        // Add some edge padding
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            zoomRect = mapView!.mapRectThatFits(zoomRect, edgePadding: UIEdgeInsetsMake(Constants.kEdgeInsetPad, Constants.kEdgeInsetPad, Constants.kEdgeInsetPad, Constants.kEdgeInsetPad))
        }
        else {
            zoomRect = mapView!.mapRectThatFits(zoomRect, edgePadding: UIEdgeInsetsMake(Constants.kEdgeInsetPhone, Constants.kEdgeInsetPhone, Constants.kEdgeInsetPhone, Constants.kEdgeInsetPhone))
        }
        
        mapView!.setVisibleMapRect(zoomRect, animated: true)
    }
    
    // MARK: NSNotification methods

    func snapRetailersDidLoad(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            SVProgressHUD.dismiss()

            let snapRetailers = notification.object as! [MKAnnotation]
            
            if snapRetailers.count > 0 {
                self.mapView!.addAnnotations(snapRetailers)
                
                self.updateVisibleMapRect()
                
                // Select nearest retailer
                let nearestRetailer = snapRetailers.first
                self.mapView!.selectAnnotation(nearestRetailer!, animated: true)
            }
        }))
    }
    
    func snapRetailersDidNotLoadWithError(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            let error = notification.object
            SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
        }))
    }
    
    func farmersMarketsDidLoad(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            SVProgressHUD.dismiss()

            let farmersMarkets = notification.object as! NSArray

            if farmersMarkets.count > 0 {
                self.mapView!.addAnnotations(farmersMarkets as! [MKAnnotation])
                
                self.updateVisibleMapRect()
            }
        }))
    }

    func farmersMarketsDidNotLoadWithError(notification: NSNotification) {        
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            let error = notification.object as! NSError
            SVProgressHUD.showErrorWithStatus(error.localizedDescription)
        }))
    }

    // MARK: Core Location Access

    func requestLocationServicesAuthorization() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100.0
        
        /*
         When the application requests to start receiving location updates that is when the user is presented with a consent dialog.
         */
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: CLLocationManagerDelegate protocol conformance
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.AuthorizedAlways ||
            authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
            mapView!.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            configureTrackingButton()
            
            locationManager.startUpdatingLocation()
            mapView!.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.first
        
        if newLocation!.coordinate.isValid {
            manager.stopUpdatingLocation()
        
            // Reverse geocode the user's location
            // Completion handler block will be executed on the main thread.
            CLGeocoder().reverseGeocodeLocation(newLocation!, completionHandler: { (placemarks, error) in
                if (error != nil) {
                    NSLog("Reverse geocode failed with error: %@", error!)
                    self.trackingButton!.enabled = false
                    return
                }
                
                // Get the top result returned by the geocoder
                let topResult = placemarks!.first
                
                let addressDictionary = topResult!.addressDictionary
                
                let formattedAddressLines = addressDictionary!["FormattedAddressLines"] as! NSArray
                
                let addressString = formattedAddressLines.componentsJoinedByString(", ")

                self.mapView?.userLocation.subtitle = addressString
                
                self.trackingButton?.enabled = true
                
                struct Holder {
                    static var didSetRegion = false
                }
                
                // Set the map's region if it's not set
                if Holder.didSetRegion == false {
                    self.setAnnotationsForCoordinate(topResult!.location!.coordinate)
                    
                    Holder.didSetRegion = true
                }
            })
        }
    }
    
    // MARK: MKMapViewDelegate protocol conformance

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let retailerPinID = "com.shrtlist.retailerPin"
        let farmersMarketPinID = "com.shrtlist.farmersMarketPin"
        let searchPinID = "com.shrtlist.searchPin"
        
        var pinAnnotationView: MKPinAnnotationView?
        
        if annotation.isKindOfClass(SnapRetailer) {
            // Try to dequeue an existing annotation view first
            pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(retailerPinID) as? MKPinAnnotationView
            
            if (pinAnnotationView == nil) {
                // If an existing annotation view was not available, create one
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: retailerPinID)
                pinAnnotationView!.canShowCallout = true
                pinAnnotationView!.pinTintColor = MKPinAnnotationView.redPinColor()
                pinAnnotationView!.animatesDrop = true
                    
                // Add Detail Disclosure button
                let button = UIButton(type: UIButtonType.DetailDisclosure)
                button.showsTouchWhenHighlighted = true
                pinAnnotationView!.rightCalloutAccessoryView = button
                
                let sfIconView = UIImageView(image: UIImage(named: "snap"))
                pinAnnotationView!.leftCalloutAccessoryView = sfIconView
                
                // Create a multi-line UILabel to use as the detailCalloutAccessoryView
                let addressLabel = UILabel()
                addressLabel.numberOfLines = 0
                addressLabel.text = annotation.subtitle!
                
                pinAnnotationView!.detailCalloutAccessoryView = addressLabel
            }
            else
            {
                pinAnnotationView!.annotation = annotation;
            }
        }
        else if annotation.isKindOfClass(FarmersMarket) {
            // Try to dequeue an existing annotation view first
            pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(farmersMarketPinID) as? MKPinAnnotationView
            
            if (pinAnnotationView == nil) {
                // If an existing annotation view was not available, create one
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier:farmersMarketPinID)
                pinAnnotationView!.canShowCallout = true
                pinAnnotationView!.pinTintColor = MKPinAnnotationView.purplePinColor()
                pinAnnotationView!.animatesDrop = true
                
                // Add Detail Disclosure button
                let button = UIButton(type: UIButtonType.DetailDisclosure)
                button.showsTouchWhenHighlighted = true
                pinAnnotationView!.rightCalloutAccessoryView = button
                
                let sfIconView = UIImageView(image: UIImage(named: "farmersmarket"))
                pinAnnotationView!.leftCalloutAccessoryView = sfIconView
                
                // Create a multi-line UILabel to use as the detailCalloutAccessoryView
                let addressLabel = UILabel()
                addressLabel.numberOfLines = 0
                addressLabel.text = annotation.subtitle!
                
                pinAnnotationView!.detailCalloutAccessoryView = addressLabel
            }
            else
            {
                pinAnnotationView!.annotation = annotation
            }
        }
        else {
            // Try to dequeue an existing annotation view first
            pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(searchPinID) as? MKPinAnnotationView
            
            if (pinAnnotationView == nil) {
                // If an existing annotation view was not available, create one
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier:searchPinID)
                pinAnnotationView!.canShowCallout = true
                pinAnnotationView!.pinTintColor = MKPinAnnotationView.greenPinColor()
                pinAnnotationView!.animatesDrop = true
                
                // Create a multi-line UILabel to use as the detailCalloutAccessoryView
                let addressLabel = UILabel()
                addressLabel.numberOfLines = 0
                addressLabel.text = annotation.subtitle!
                
                pinAnnotationView!.detailCalloutAccessoryView = addressLabel
            }
            else
            {
                pinAnnotationView!.annotation = annotation
            }
        }
        
        pinAnnotationView!.annotation = annotation
        
        let addressLabel = pinAnnotationView!.detailCalloutAccessoryView as! UILabel
        addressLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        addressLabel.text = annotation.subtitle!
        
        return pinAnnotationView
    }

    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        trackingButton?.enabled = false
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        redoSearchView!.hidden = true
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = mapView.selectedAnnotations.first
        
        let retailer = annotation as! SnapRetailer
        
        MKMapItem.openMapWithDestination(retailer)
    }
    
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        if mode == MKUserTrackingMode.Follow {
            centerAction()
        }
    }

    // MARK: UISearchBarDelegate protocol conformance

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Dismiss the keyboard if it's currently open
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        setSearchBarAnnotation(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    // MARK: UIGestureRecognizerDelegate protocol conformance

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
