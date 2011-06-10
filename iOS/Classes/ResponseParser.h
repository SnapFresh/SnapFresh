//
//  ResponseParser
//

@interface ResponseParser : NSObject
{
}

// Parses the Snapfresh response string into an array of MKPointAnnotations
+ (NSArray *)parseResponse:(NSString *)returnString;

@end
