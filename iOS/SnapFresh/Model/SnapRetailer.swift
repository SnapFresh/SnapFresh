/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

import AddressBookUI
import CoreLocation
import MapKit

class SnapRetailer: MKPlacemark {
    
    var _distance: Double
    var _name: String

    // MARK: Designated initializer
    init(dictionary: NSDictionary) {
        let street = dictionary["street"]
        let city = dictionary["city"]
        let state = dictionary["state"]
        let zip = dictionary["zip"]
        let lat = dictionary["lat"]
        let lon = dictionary["lon"]
        
        // Create the address dictionary
        let addressDictionary: [String : AnyObject] = [String(kABPersonAddressStreetKey):street!,
                                String(kABPersonAddressCityKey):city!,
                                String(kABPersonAddressStateKey):state!,
                                String(kABPersonAddressZIPKey):zip!]
        
        _name = dictionary["name"] as! String
        let distanceString = dictionary["distance"] as! String
        _distance = NSNumberFormatter().numberFromString(distanceString)!.doubleValue
        
        // Create the coordinate
        let coordinate = CLLocationCoordinate2DMake((lat?.doubleValue)!, (lon?.doubleValue)!)
        
        // Call our parent's initializer
        super.init(coordinate: coordinate, addressDictionary: addressDictionary)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override MKAnnotation protocol accessors

    override var title: String? {
        get {
            return _name
        }
    }

    override var subtitle: String? {
        get {
            let postalAddressString = ABCreateStringWithAddressDictionary(self.addressDictionary!, false)
            return postalAddressString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        }
    }

}
