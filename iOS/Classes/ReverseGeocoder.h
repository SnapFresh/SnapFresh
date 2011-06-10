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
- (void)updateGeoCoderWithLocation:(CLLocation *)location;

@end
