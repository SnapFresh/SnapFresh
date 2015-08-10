//
//  FarmersMarket.h
//  SnapFresh
//
//  Created by Marco Abundo on 8/8/15.
//  Copyright © 2015 shrtlist.com. All rights reserved.
//

@import MapKit;

@interface FarmersMarket : MKPlacemark

- (instancetype)init __attribute__((unavailable("Must use initWithDictionary: instead.")));

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

// Expose this property so it can be set after initialization
@property (nonatomic, strong) NSString *marketName;

@end
