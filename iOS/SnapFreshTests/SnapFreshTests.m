//
//  SnapFreshTests.m
//  SnapFreshTests
//
//  Created by Marco Abundo on 11/23/13.
//  Copyright (c) 2013 shrtlist.com. All rights reserved.
//

@import XCTest;
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

@end
