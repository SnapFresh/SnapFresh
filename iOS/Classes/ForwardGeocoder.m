//
//  ForwardGeocoder
//

#import "ForwardGeocoder.h"
#import "Reachability.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation ForwardGeocoder

// Google Maps API URL
static NSString *kApiUrl = @"http://maps.google.com/maps/geo?q=%@&key=%@&output=csv";

// Google Maps API key
static NSString *kApiKey = @"ABQIAAAAAQDWMJkctRvZkqkxCunDzhQn8vBtndM0mf8Dz_CkaUVlQbAGhxRgq6DsG1k8tIMNOhhfY3zjqaajZQ";

+ (CLLocationCoordinate2D)fetchGeocodeForAddress:(NSString *)address
{	
	CLLocationCoordinate2D coord = kCLLocationCoordinate2DInvalid;

	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	
	if ([internetReach currentReachabilityStatus] != NotReachable)
	{
		// Create the URL with Google's geocoding service
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kApiUrl, 
										   [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], kApiKey]];
		
		// Show network activity indicator
		UIApplication *app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = YES;
		
		NSStringEncoding encoding;
		NSError *error;
		
		// Read data from the URL. The geocode is contained in the return string
		NSString *locationString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
		
		// Hide network activity indicator
		app.networkActivityIndicatorVisible = NO;
		
		// Parse the return string for the geocode
		NSArray *listItems = [locationString componentsSeparatedByString:@","];
		
		if ([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"])
		{
			// Google returns 7 digits of precision?
			coord.latitude = [[listItems objectAtIndex:2] doubleValue];
			coord.longitude = [[listItems objectAtIndex:3] doubleValue];
		}
	}
	
	return coord;
}

@end