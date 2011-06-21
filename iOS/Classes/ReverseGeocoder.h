//
//  ReverseGeocoder
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ReverseGeocoder : NSObject <MKReverseGeocoderDelegate>
{
	MKReverseGeocoder *mkReverseGeocoder;
	MKMapView *mapView;
}

- (id)initWithMapView:(MKMapView *)mapView;
- (void)updateGeoCoderWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
