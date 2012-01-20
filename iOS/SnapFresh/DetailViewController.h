//
//  DetailViewController.h
//  SnapFresh
//
//  Created by Marco Abundo on 1/18/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol DetailViewControllerDelegate;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UISearchBarDelegate, MKMapViewDelegate>
{
    dispatch_queue_t dispatchQueue;
}

@property (nonatomic, weak) id <DetailViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

/**
 * A delegate implements this protocol to be notified when the map is finished loading.
 */
@protocol DetailViewControllerDelegate
- (void)annotationsDidLoad:(DetailViewController *)controller;
@end
