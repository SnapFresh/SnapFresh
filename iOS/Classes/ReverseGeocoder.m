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

- (void)dealloc
{
	[mkReverseGeocoder release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Start the reverse geocoder

- (void)updateGeoCoderWithLocation:(CLLocation *)location
{	
	// Do reverse-geo lookup
	if (mkReverseGeocoder)
	{
		[mkReverseGeocoder cancel];
		[mkReverseGeocoder release];
	}
	
	mkReverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
	mkReverseGeocoder.delegate = self;
	[mkReverseGeocoder start];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)reverseGeocoder didFindPlacemark:(MKPlacemark *)placemark
{	
	NSString *subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
	mapView.userLocation.subtitle = subtitle;
	[subtitle release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)reverseGeocoder didFailWithError:(NSError *)error
{
	[reverseGeocoder cancel];	
	mapView.userLocation.subtitle = nil;
}

@end