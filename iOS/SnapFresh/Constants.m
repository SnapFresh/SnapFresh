//
//  Constants.m
//  SnapFresh
//
//  Created by Marco Abundo on 6/17/12.
//  Copyright (c) 2013 shrtlist.com. All rights reserved.
//

// SnapFresh API base URL
NSString * const kSnapFreshBaseURL = @"http://snapfresh.org";

// SnapFresh API endpoint
NSString * const kSnapFreshEndpoint = @"/retailers/nearaddy.json/";

// USDA farmers market API base URL
NSString * const kUSDABaseURL = @"http://search.ams.usda.gov";

// USDA farmers market location search API endpoint
NSString * const kUSDAFarmersMarketSearchEndpoint = @"/farmersmarkets/mobile/mobile.svc/locSearch?";

// USDA farmers market detail API endpoint
NSString * const kUSDAFarmersMarketDetailEndpoint = @"/farmersmarkets/v1/data.svc/mktDetail?";

// SnapFresh timeout interval
NSTimeInterval const kSnapFreshTimeout = 10.0;

// Animation duration
CGFloat const kAnimationDuration = 0.5;

// Edge insets
CGFloat const kEdgeInsetPhone = 40.0;
CGFloat const kEdgeInsetPad = 100.0;

// Map image name
NSString * const kMapImageName = @"103-map";

// List image name
NSString * const kListImageName = @"259-list";