/*
 * Copyright 2014 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

import CoreLocation
import Foundation

/*!
@class RequestController
@abstract
A RequestController creates and sends the request
for SNAP retailers and parses the response.
*/
class RequestController {
    let kMaxFarmersMarkets = 5

    // MARK: SnapFresh request

    /*!
     * @abstract Send a SNAP retailer request for a coordinate
     *
     * @param coordinate around which SNAP retailers should be located
     */
    func sendSNAPRequestForCoordinate(coordinate: CLLocationCoordinate2D) {
        if CLLocationCoordinate2DIsValid(coordinate) {
            let coordinateString = NSString(format: "%f,%f", coordinate.latitude, coordinate.longitude)
            let urlString = NSString(format: "%@%@?address=%@", Constants.kSnapFreshBaseURL, Constants.kSnapFreshEndpoint, coordinateString)
            let url = NSURL(string: urlString as String)
            let request = NSURLRequest(URL: url!)

            let app = UIApplication.sharedApplication()
            app.networkActivityIndicatorVisible = true
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                app.networkActivityIndicatorVisible = false

                if (error != nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.kSNAPRetailersDidNotLoadNotification, object: error)
                }
                else {
                    let snapRetailers = self.snapRetailersFromJSON(data!, error:error)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.kSNAPRetailersDidLoadNotification, object: snapRetailers)
                }
            })
            
            task.resume()
        }
        else {
            let error = NSError(domain: "com.shrtlist.snapfresh", code: 99, userInfo: [NSLocalizedFailureReasonErrorKey:"Invalid coordinate"])
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.kSNAPRetailersDidNotLoadNotification, object: error)
        }
    }
    
    /*!
     * @abstract Parse the JSON response
     *
     * @param json response
     * @returns array of SnapRetailers
     */
    func snapRetailersFromJSON(objectNotation: NSData?, error: NSError?) -> [SnapRetailer] {
        
        var snapRetailers: [SnapRetailer] = []
        
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(objectNotation!, options: .AllowFragments)
            
            // Get the JSON array of retailers
            let retailersJSON = jsonDictionary["retailers"] as! NSArray
            
            for retailerJSON in retailersJSON {
                // Get the JSON dictionary of a retailer
                let retailerDictionary = retailerJSON["retailer"] as! NSDictionary
                let retailer = SnapRetailer(dictionary: retailerDictionary)
                snapRetailers.append(retailer)
            }
        }
        catch {
            print(error)
        }
        
        return snapRetailers
    }

    // MARK: USDA farmers market requests

    /*!
     * @abstract Send a USDA farmers market request for a coordinate
     *
     * @param coordinate around which farmers markets should be located
     */
    func sendFarmersMarketRequestForCoordinate(coordinate: CLLocationCoordinate2D) {
        if CLLocationCoordinate2DIsValid(coordinate) {
            let urlString = NSString(format: "%@%@y=%f&x=%f&SNAP=1", Constants.kUSDABaseURL, Constants.kUSDAFarmersMarketSearchEndpoint, coordinate.latitude, coordinate.longitude)
            let url = NSURL(string: urlString as String)
            let request = NSURLRequest(URL: url!)
            
            let app = UIApplication.sharedApplication()
            app.networkActivityIndicatorVisible = true
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                app.networkActivityIndicatorVisible = false
                
                if (error != nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.kFarmersMarketsDidNotLoadNotification, object: error)
                }
                else {
                    // Create our HTML parser
                    let htmlParser = TFHpple(HTMLData: data)

                    // Get all the <a> tags
                    let xpathQueryString = "//a"
                    let marketNodes = htmlParser.searchWithXPathQuery(xpathQueryString) as NSArray
                    
                    if marketNodes.count == 0 {
                        self.postInvalidCoordinateErrorNotification()
                    }
                    else {
                        let markets = NSMutableArray(capacity: self.kMaxFarmersMarkets)
                        
                        var index = 0
                        
                        for element in marketNodes {
                            
                            if (index == self.kMaxFarmersMarkets) {
                                break
                            }
                            
                            index++
                            
                            // Get the farmers market ID
                            let marketID = element.objectForKey("id")
                            
                            // Get the farmers market name
                            var marketName = element.firstTextChild().content
                            
                            // Strip off the distance numbers prepended to the market name
                            let range = marketName.rangeOfString(" ")
                            marketName = marketName.substringFromIndex((range?.startIndex.successor())!)

                            let marketDict = ["id":marketID!,
                                "marketName":marketName] as NSDictionary
                            
                            markets.addObject(marketDict)
                        }

                        self.sendFarmersMarketDetailRequest(markets, completionHandler: { (farmersMarkets, error) in
                            if (error != nil) {
                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.kFarmersMarketsDidNotLoadNotification, object:error)
                            }
                            else {
                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.kFarmersMarketsDidLoadNotification, object: farmersMarkets)
                            }
                        })
                    }
                }
            })
            
            task.resume()
        }
        else {
            postInvalidCoordinateErrorNotification()
        }
    }
    
    func postInvalidCoordinateErrorNotification() {
        let error = NSError(domain: "com.shrtlist.snapfresh", code:99, userInfo: [NSLocalizedFailureReasonErrorKey:"Invalid coordinate"])
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.kFarmersMarketsDidNotLoadNotification, object: error)
    }

    /*!
     * @abstract Send a USDA farmers market detail request
     *
     * @param markets for which details will be fetched
     */
    func sendFarmersMarketDetailRequest(markets: NSArray, completionHandler: (farmersMarkets: NSArray?, error: NSError?) -> Void) {
        if (markets.count == 0) {
            let error = NSError(domain: "com.shrtlist.snapfresh", code:100, userInfo: [NSLocalizedFailureReasonErrorKey : "Empty array"])
            
            completionHandler(farmersMarkets: nil, error: error)
        }
        
        let tmpArray = NSMutableArray(capacity: markets.count)
        
        var index = 0
        
        for farmersMarketDictionary in markets {
        
            let farmersMarketID = farmersMarketDictionary["id"] as! NSString
            let farmersMarketName = farmersMarketDictionary["marketName"] as! String
                
            let urlString = NSString(format:"%@%@id=%@", Constants.kUSDABaseURL, Constants.kUSDAFarmersMarketDetailEndpoint, farmersMarketID)
            let url = NSURL(string: urlString as String)
            let request = NSURLRequest(URL: url!)

            let app = UIApplication.sharedApplication()
            app.networkActivityIndicatorVisible = true

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                app.networkActivityIndicatorVisible = false

                if (error != nil) {
                    completionHandler(farmersMarkets: nil, error: error!)
                }
                else {
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary

                        let farmersMarket = FarmersMarket(dictionary: jsonDictionary)

                        if CLLocationCoordinate2DIsValid(farmersMarket.coordinate) {
                            farmersMarket.marketName = farmersMarketName
                            
                            tmpArray.addObject(farmersMarket)
        
                            index++
                            
                            if (index == markets.count) {
                                completionHandler(farmersMarkets: tmpArray, error: nil)
                            }
                        }
                    }
                    catch {
                        print(error)
                        completionHandler(farmersMarkets: tmpArray, error: error as NSError)
                    }
                }
            })
            
            task.resume()
        }
    }

}
