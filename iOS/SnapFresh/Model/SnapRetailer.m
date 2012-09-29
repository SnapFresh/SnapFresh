/*
 * Copyright 2012 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

#import "SnapRetailer.h"
#import <AddressBook/AddressBook.h>


@implementation SnapRetailer

@synthesize name = _name;
@synthesize address;
@synthesize mapAddress;
@synthesize distance = _distance;

#pragma mark - Designated initializer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    _name = [dictionary valueForKey:@"name"];
    _distance = [dictionary valueForKey:@"distance"];
    
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
    
    NSString *street = [dictionary valueForKey:@"street"];
    NSString *city = [dictionary valueForKey:@"city"];
    NSString *state = [dictionary valueForKey:@"state"];
    NSString *zip = [dictionary valueForKey:@"zip"];
    NSNumber *lat = [dictionary valueForKey:@"lat"];
    NSNumber *lon = [dictionary valueForKey:@"lon"];
    
    [addressDictionary setValue:street forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDictionary setValue:city forKey:(NSString *)kABPersonAddressCityKey];
    [addressDictionary setValue:state forKey:(NSString *)kABPersonAddressStateKey];
    [addressDictionary setValue:zip forKey:(NSString *)kABPersonAddressZIPKey];

    CLLocationCoordinate2D coordinate = { [lat doubleValue], [lon doubleValue] };
    
    self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary];
    
    return self;
}

#pragma mark - Address getter implementations

- (NSString *)address
{
    NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@", self.thoroughfare, self.locality, self.administrativeArea];
    return addressString;
}

- (NSString *)mapAddress
{
    NSString *mapString = [NSString stringWithFormat:@"%@+%@+%@", self.thoroughfare, self.locality, self.administrativeArea];
    return mapString;
}

#pragma mark - MKAnnotation conformance

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

@end