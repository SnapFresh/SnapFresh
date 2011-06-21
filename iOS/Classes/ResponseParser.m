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

#pragma mark -
#pragma mark Parses the Snapfresh response string

+ (NSArray *)parse:(NSString *)response
{
	NSMutableArray *annotations = nil;
	
	if (response)
	{
		annotations = [[[NSMutableArray alloc] init] autorelease];
		
		// The store names and addresses are contained in the return string
		NSArray *returnArray = [response componentsSeparatedByString:@"\n\n"];
		
		for (NSString *subString in returnArray)
		{
			// Separate the substring further
			NSArray *subArray = [subString componentsSeparatedByString:@"\n"];
			
			MKPointAnnotation *annotation = [self getAnnotationFromArray:subArray];
			
			[annotations addObject:annotation];
		}
	}
	
	return annotations;
}

#pragma mark -
#pragma mark Create annotation from store data

+ (id <MKAnnotation>)getAnnotationFromArray:(NSArray *)array
{
	MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
	annotation.title = [array objectAtIndex:0]; // Store name
	annotation.subtitle = [array objectAtIndex:1]; // Street address
	
	// Fetch the geocode for the street address
	annotation.coordinate = [ForwardGeocoder fetchGeocodeForAddress:annotation.subtitle];
	
	return annotation;
}

@end
