//
//  FarmersMarket.m
//  SnapFresh
//
//  Created by Marco Abundo on 8/8/15.
//  Copyright © 2015 shrtlist.com. All rights reserved.
//

@import Contacts;
#import "FarmersMarket.h"

@interface FarmersMarket () // Class extension
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) NSString *products;
@property (nonatomic, readonly) NSString *schedule;
@end

@implementation FarmersMarket

#pragma mark - Designated initializer

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *marketDetails = dictionary[@"marketdetails"];
    NSArray *addressItems = [marketDetails[@"Address"] componentsSeparatedByString:@", "];
    
    id street = [NSNull null];
    id city = [NSNull null];
    id state = [NSNull null];
    id zip = [NSNull null];
    
    if (addressItems.count == 2) {
        city = addressItems[0];
        state = addressItems[1];
    }
    else if (addressItems.count == 3)
    {
        id thirdItem = addressItems[2];
        
        if ([self hasLeadingNumberInString:thirdItem]) {
            // third item is ZIP code
            city = addressItems[0];
            street = addressItems[1];
            zip = addressItems[2];
        }
        else
        {
            street = addressItems[0];
            city = addressItems[1];
            state = addressItems[2];
        }
    }
    else if (addressItems.count > 3)
    {
        street = addressItems[0];
        city = addressItems[1];
        state = addressItems[2];
        zip = addressItems[3];
    }
    
    // Create the address dictionary
    NSDictionary *addressDictionary = @{(NSString *)CNPostalAddressStreetKey:street,
                                        (NSString *)CNPostalAddressCityKey:city,
                                        (NSString *)CNPostalAddressStateKey:state,
                                        (NSString *)CNPostalAddressPostalCodeKey:zip};
    
    NSString *googleLink = marketDetails[@"GoogleLink"];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:googleLink];
    NSURLQueryItem *queryItem = [urlComponents.queryItems firstObject];
    NSString *value = queryItem.value;
    NSArray *latLongArray = [value componentsSeparatedByString:@" "];
    NSNumber *lat = latLongArray[0];
    NSNumber *lon = latLongArray[1];
    
    // Create the coordinate
    CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
    
    if (lat && lon)
    {
        coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
    }
    
    // Call our parent's initializer
    self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary];
    
    if (self)
    {
        CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
        postalAddress.street = [addressDictionary objectForKey:CNPostalAddressStreetKey];
        postalAddress.city = [addressDictionary objectForKey:CNPostalAddressCityKey];
        postalAddress.state = [addressDictionary objectForKey:CNPostalAddressStateKey];
        postalAddress.postalCode = [addressDictionary objectForKey:CNPostalAddressPostalCodeKey];
        
        NSString *postalAddressString = [CNPostalAddressFormatter stringFromPostalAddress:postalAddress style:CNPostalAddressFormatterStyleMailingAddress];
        
        _address = [postalAddressString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        _products = marketDetails[@"Products"];

        _schedule = marketDetails[@"Schedule"];
    }
    
    return self;
}

- (BOOL)hasLeadingNumberInString:(NSString *)s
{
    if (s)
        return [s length] && isnumber([s characterAtIndex:0]);
    else
        return NO;
}

#pragma mark - Override MKAnnotation protocol accessors

- (NSString *)title
{
    return self.marketName;
}

- (NSString *)subtitle
{
    return self.address;
}

@end
