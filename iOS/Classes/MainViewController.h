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

@property (nonatomic, unsafe_unretained) IBOutlet MKMapView *mapView;
	
@end