/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@import Contacts;
#import "SnapRetailer.h"

@implementation SnapRetailer

@synthesize name = _name;

#pragma mark - Designated initializer

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSString *street = [dictionary objectForKey:@"street"];
    NSString *city = [dictionary objectForKey:@"city"];
    NSString *state = [dictionary objectForKey:@"state"];
    NSString *zip = [dictionary objectForKey:@"zip"];
    NSNumber *lat = [dictionary objectForKey:@"lat"];
    NSNumber *lon = [dictionary objectForKey:@"lon"];
    
    // Create the address dictionary
    NSDictionary *addressDictionary = @{(NSString *)CNPostalAddressStreetKey:street,
                                        (NSString *)CNPostalAddressCityKey:city,
                                        (NSString *)CNPostalAddressStateKey:state,
                                        (NSString *)CNPostalAddressPostalCodeKey:zip};

    // Create the coordinate
    CLLocationCoordinate2D coordinate = { [lat doubleValue], [lon doubleValue] };
    
    // Call our parent's initializer
    self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary];
    
    if (self)
    {
        _name = [dictionary objectForKey:@"name"];
        
        CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
        postalAddress.street = [addressDictionary objectForKey:CNPostalAddressStreetKey];
        postalAddress.city = [addressDictionary objectForKey:CNPostalAddressCityKey];
        postalAddress.state = [addressDictionary objectForKey:CNPostalAddressStateKey];
        postalAddress.postalCode = [addressDictionary objectForKey:CNPostalAddressPostalCodeKey];
        
        NSString *postalAddressString = [CNPostalAddressFormatter stringFromPostalAddress:postalAddress style:CNPostalAddressFormatterStyleMailingAddress];
        
        _address = [postalAddressString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        _distance = [dictionary objectForKey:@"distance"];
    }
    
    return self;
}

#pragma mark - Override MKAnnotation protocol accessors

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

@end
