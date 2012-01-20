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

@implementation SnapRetailer

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

#pragma mark - Designated initializer

- (id)initWithName:(NSString *)name andAddress:(NSString *)address
{
    self = [super init];
    
    if (self)
    {
        _name = name;
        _address = address;
    }
    
    return self;
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

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end
