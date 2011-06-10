//
//  ResponseParser
//

#import "ResponseParser.h"
#import "ForwardGeocoder.h"
#import <MapKit/MapKit.h>

@interface ResponseParser ()

+ (MKPointAnnotation *)getAnnotationFromArray:(NSArray *)array;

@end


@implementation ResponseParser

+ (NSArray *)parseResponse:(NSString *)returnString
{
	NSMutableArray *addressesArray = nil;
	
	if (returnString)
	{
		addressesArray = [[[NSMutableArray alloc] init] autorelease];
		
		// The store names and addresses are contained in the return string
		NSArray *returnArray = [returnString componentsSeparatedByString:@"\n\n"];
		
		for (NSString *subString in returnArray)
		{
			// Separate the substring further
			NSArray *subArray = [subString componentsSeparatedByString:@"\n"];
			
			MKPointAnnotation *annotation = [self getAnnotationFromArray:subArray];
			
			[addressesArray addObject:annotation];
		}
	}
	
	return addressesArray;
}

+ (MKPointAnnotation *)getAnnotationFromArray:(NSArray *)array
{
	MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
	annotation.title = [array objectAtIndex:0]; // Store name
	annotation.subtitle = [array objectAtIndex:1]; // Street address
	
	// Fetch the geocode for the street address
	annotation.coordinate = [ForwardGeocoder fetchGeocodeForAddress:annotation.subtitle];
	
	return annotation;
}

@end
