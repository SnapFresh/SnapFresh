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
#import <AddressBookUI/AddressBookUI.h>

@implementation SnapRetailer

@synthesize name;
@synthesize address;
@synthesize coordinate;
@synthesize street;
@synthesize state;
@synthesize lat;
@synthesize lon;
@synthesize city;
@synthesize mapAddress;

#pragma mark - Designated initializer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self)
    {
        for (NSString *key in [dictionary allKeys])
        {
            @try
            {
                NSString *value = [dictionary objectForKey:key];
                [self setValue:value forKey:key];
            }
            @catch (NSException *exception)
            {
                //NSLog(@"%@", exception);
            }
        }
    }
    
    return self;
}

#pragma mark - address getter implementations

- (NSString *)address
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.street, self.city, self.state];
}

- (NSString *)mapAddress
{
    NSString *mapString = [NSString stringWithFormat:@"%@ %@ %@", self.street, city, state];
    NSString *formattedMapString = [mapString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return formattedMapString;
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

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord2D = { [self.lat doubleValue], [self.lon doubleValue] };
	
	return coord2D;
}

@end
