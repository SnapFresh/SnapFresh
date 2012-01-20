//
//  SnapRetailer.h
//  SnapFresh
//
//  Created by Marco Abundo on 1/19/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SnapRetailer : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *address;

// The designated initializer
- (id)initWithName:(NSString *)name andAddress:(NSString *)address;

@end
