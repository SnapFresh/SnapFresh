//
//  SnapFreshTests.m
//  SnapFreshTests
//
//  Created by Marco Abundo on 11/23/13.
//  Copyright (c) 2013 shrtlist.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBookUI/AddressBookUI.h>
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
    NSDictionary *addressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"111 West St", (NSString *)kABPersonAddressStreetKey,
                                       @"San Francisco", (NSString *)kABPersonAddressCityKey,
                                       @"CA", (NSString *)kABPersonAddressStateKey,
                                       @"94111", (NSString *)kABPersonAddressZIPKey, nil];
    
    SnapRetailer *retailer = [[SnapRetailer alloc] initWithDictionary:addressDictionary];
    XCTAssertNotNil(retailer, @"Expected non-nil retailer");
}

@end
