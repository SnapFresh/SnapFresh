//
//  SnapRetailer.m
//  SnapFresh
//
//  Created by Marco Abundo on 1/19/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import "SnapRetailer.h"

@implementation SnapRetailer

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

#pragma mark - Designated initalizer

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
