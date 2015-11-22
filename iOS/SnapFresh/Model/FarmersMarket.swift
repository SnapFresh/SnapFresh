//
//  FarmersMarket.m
//  SnapFresh
//
//  Created by Marco Abundo on 8/8/15.
//  Copyright © 2015 shrtlist.com. All rights reserved.
//

import AddressBookUI
import CoreLocation
import MapKit

class FarmersMarket: MKPlacemark {

    // Variable stored properties
    var marketName: String = ""
    
    // MARK: Designated initializer
    init(dictionary: NSDictionary) {
        let marketDetails = dictionary["marketdetails"] as! NSDictionary
        let addressItems = marketDetails["Address"]!.componentsSeparatedByString(", ")
        
        var street = ""
        var city = ""
        var state = ""
        var zip = ""
        
        if (addressItems.count == 2) {
            city = addressItems[0];
            state = addressItems[1];
        }
        else if (addressItems.count == 3) {
            let thirdItem = addressItems[2] as String
            
            if NSString.hasLeadingNumberInString(thirdItem) {
                // third item is ZIP code
                city = addressItems[0];
                street = addressItems[1];
                zip = addressItems[2];
            }
            else {
                street = addressItems[0];
                city = addressItems[1];
                state = addressItems[2];
            }
        }
        else if (addressItems.count > 3) {
            street = addressItems[0];
            city = addressItems[1];
            state = addressItems[2];
            zip = addressItems[3];
        }
        
        // Create the address dictionary
        let addressDictionary: [String : AnyObject] = [String(kABPersonAddressStreetKey):street,
                                            String(kABPersonAddressCityKey):city,
                                            String(kABPersonAddressStateKey):state,
                                            String(kABPersonAddressZIPKey):zip]
        
        let googleLink = marketDetails["GoogleLink"] as! String
        let urlComponents = NSURLComponents(string: googleLink)
        let queryItem = urlComponents!.queryItems!.first
        let value = queryItem!.value
        let latLongArray = value!.componentsSeparatedByString(" ")
        let latString = latLongArray[0].stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())
        let finalLatString = latString.stringByReplacingOccurrencesOfString(",", withString: "")
        let lonString = latLongArray[1].stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())

        let lat = NSNumberFormatter().numberFromString(finalLatString)!.doubleValue
        let lon = NSNumberFormatter().numberFromString(lonString)!.doubleValue
        
        // Create the coordinate
        var coord = kCLLocationCoordinate2DInvalid
        
        if (lat != kCLLocationCoordinate2DInvalid.latitude && lon != kCLLocationCoordinate2DInvalid.longitude) {
            coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        // Call our parent's initializer
        super.init(coordinate: coord, addressDictionary: addressDictionary)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override MKAnnotation protocol accessors

    override var title: String? {
        get {
            return self.marketName;
        }
    }

    override var subtitle: String? {
        get {
            let postalAddressString = ABCreateStringWithAddressDictionary(self.addressDictionary!, false)
            
            return postalAddressString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        }
    }

}
