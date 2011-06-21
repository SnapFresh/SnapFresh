//
//  ResponseParser
//

@interface ResponseParser : NSObject
{
}

// Parses the Snapfresh response string into an array of MKPointAnnotations
+ (NSArray *)parse:(NSString *)response;

@end
