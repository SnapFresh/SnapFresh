//
//  MainViewController
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FlipsideViewController.h"
#import "ReverseGeocoder.h"

@interface MainViewController : UIViewController <MKMapViewDelegate,
												  CLLocationManagerDelegate,
												  UISearchBarDelegate,
												  FlipsideViewControllerDelegate>
{
	CLLocationManager *locationManager;
	CLLocationCoordinate2D centerCoordinate;
	ReverseGeocoder *reverseGeocoder;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *centerButton;

- (IBAction)centerAction:(id)sender;
- (IBAction)showInfo:(id)sender;
	
@end