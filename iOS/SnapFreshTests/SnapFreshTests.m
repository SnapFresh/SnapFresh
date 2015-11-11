//
//  SnapFreshTests.m
//  SnapFreshTests
//
//  Created by Marco Abundo on 11/23/13.
//  Copyright (c) 2013 shrtlist.com. All rights reserved.
//

@import XCTest;
#import "FarmersMarket.h"
#import "SnapRetailer.h"

@interface SnapFreshTests : XCTestCase

@end

@implementation SnapFreshTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSnapRetailer
{
    NSDictionary *addressDictionary = @{@"street":@"111 West St",
                                        @"city":@"San Francisco",
                                        @"state":@"CA",
                                        @"zip":@"94111",
                                        @"lat":@"37.775",
                                        @"lon":@"-122.418333333333"};
    
    SnapRetailer *retailer = [[SnapRetailer alloc] initWithDictionary:addressDictionary];
    XCTAssertEqualObjects(retailer.administrativeArea, @"CA", @"Expected equal administrativeArea");
    XCTAssertEqualObjects(retailer.thoroughfare, @"111 West St", @"Expected equal thoroughfare");
    XCTAssertEqualObjects(retailer.locality, @"San Francisco", @"Expected equal locality");
    XCTAssertNotNil(retailer.location, @"Expected non-nil location");
    XCTAssertEqualObjects(retailer.postalCode, @"94111", @"Expected equal postalCode");
}

- (void)testFarmersMarket
{
    NSDictionary *farmersMarketDictionary = @{@"marketdetails":@{@"Address":@"111 West St, San Francisco, CA, 94103",
        @"GoogleLink":@"http://maps.google.com/?q=37.786250%2C%20-122.404883%20(%22Yerba+Buena+Lane+Farmers'+Market%22)",
        @"Products":@"Baked goods; Cheese and/or dairy products; Eggs; Fresh fruit and vegetables; Fresh and/or dried herbs; Honey; Canned or preserved fruits, vegetables, jams, jellies, preserves, salsas, pickles, dried fruit, etc.; Nuts; Prepared foods (for immediate consumption)",
        @"Schedule":@"May to October Tue:1:00 PM - 6:00 PM;<br> <br> <br> "}};
    
    FarmersMarket *farmersMarket = [[FarmersMarket alloc] initWithDictionary:farmersMarketDictionary];
    XCTAssertEqualObjects(farmersMarket.administrativeArea, @"CA", @"Expected equal administrativeArea");
    XCTAssertEqualObjects(farmersMarket.thoroughfare, @"111 West St", @"Expected equal thoroughfare");
    XCTAssertEqualObjects(farmersMarket.locality, @"San Francisco", @"Expected equal locality");
    XCTAssertNotNil(farmersMarket.location, @"Expected non-nil location");
    XCTAssertEqualObjects(farmersMarket.postalCode, @"94103", @"Expected equal postalCode");
}

@end
