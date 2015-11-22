//
//  SnapFreshTests.m
//  SnapFreshTests
//
//  Created by Marco Abundo on 11/23/13.
//  Copyright (c) 2013 shrtlist.com. All rights reserved.
//

import XCTest
@testable import SnapFresh

class SnapFreshTests : XCTestCase {

    func testSnapRetailer() {
        let addressDictionary = ["name":"1 2 3 Store",
            "street":"111 West St",
            "city":"San Francisco",
            "state":"CA",
            "zip":"94111",
            "lat":"37.775",
            "lon":"-122.418333333333",
            "distance":"1.0"]
        
        let retailer = SnapRetailer(dictionary: addressDictionary)
        XCTAssertEqual(retailer.administrativeArea, "CA", "Expected equal administrativeArea")
        XCTAssertEqual(retailer.thoroughfare, "111 West St", "Expected equal thoroughfare")
        XCTAssertEqual(retailer.locality, "San Francisco", "Expected equal locality")
        XCTAssertNotNil(retailer.location, "Expected non-nil location")
        XCTAssertEqual(retailer.postalCode, "94111", "Expected equal postalCode")
    }

    func testFarmersMarket() {
        let farmersMarketDictionary = ["marketdetails":
            ["Address":"111 West St, San Francisco, CA, 94103",
            "GoogleLink":"http://maps.google.com/?q=37.786250%2C%20-122.404883%20(%22Yerba+Buena+Lane+Farmers'+Market%22)",
            "Products":"Baked goods; Cheese and/or dairy products; Eggs; Fresh fruit and vegetables; Fresh and/or dried herbs; Honey; Canned or preserved fruits, vegetables, jams, jellies, preserves, salsas, pickles, dried fruit, etc.; Nuts; Prepared foods (for immediate consumption)",
            "Schedule":"May to October Tue:1:00 PM - 6:00 PM;<br> <br> <br> "]]
        
        let farmersMarket = FarmersMarket(dictionary: farmersMarketDictionary)
        XCTAssertEqual(farmersMarket.administrativeArea, "CA", "Expected equal administrativeArea")
        XCTAssertEqual(farmersMarket.thoroughfare, "111 West St", "Expected equal thoroughfare")
        XCTAssertEqual(farmersMarket.locality, "San Francisco", "Expected equal locality")
        XCTAssertNotNil(farmersMarket.location, "Expected non-nil location")
        XCTAssertEqual(farmersMarket.postalCode, "94103", "Expected equal postalCode")
    }

}
