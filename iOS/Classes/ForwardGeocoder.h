//
//  ForwardGeocoder
//

#import <CoreLocation/CoreLocation.h>

@interface ForwardGeocoder : NSObject
{
}

+ (CLLocationCoordinate2D)fetchGeocodeForAddress:(NSString *)address;

@end
