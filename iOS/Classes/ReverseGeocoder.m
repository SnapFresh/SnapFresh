//
//  ReverseGeocoder
//

#import "ReverseGeocoder.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation ReverseGeocoder

#pragma mark -
#pragma mark Initialization and deallocation

- (id)initWithMapView:(MKMapView *)newMapView
{
	self = [super init];
	
	if (self)
	{
		mapView = newMapView;
	}
	
	return self;
}


#pragma mark -
#pragma mark Start the reverse geocoder

- (void)updateGeoCoderWithCoordinate:(CLLocationCoordinate2D)coordinate
{	
	// Do reverse-geo lookup
	if (mkReverseGeocoder)
	{
		[mkReverseGeocoder cancel];
	}
	
	mkReverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	mkReverseGeocoder.delegate = self;
	[mkReverseGeocoder start];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)reverseGeocoder didFindPlacemark:(MKPlacemark *)placemark
{	
	NSString *subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
	mapView.userLocation.subtitle = subtitle;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)reverseGeocoder didFailWithError:(NSError *)error
{
	[reverseGeocoder cancel];	
	mapView.userLocation.subtitle = nil;
}

@end