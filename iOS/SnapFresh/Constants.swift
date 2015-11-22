/*
 * Copyright 2015 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

import Foundation

/*!
@struct Constants
@abstract
SnapFresh constants
*/
struct Constants {
    // SnapFresh API base URL
    static let kSnapFreshBaseURL = "http://snapfresh.org"

    // SnapFresh API endpoint
    static let kSnapFreshEndpoint = "/retailers/nearaddy.json/"

    // USDA farmers market API base URL
    static let kUSDABaseURL = "http://search.ams.usda.gov"

    // USDA farmers market location search API endpoint
    static let kUSDAFarmersMarketSearchEndpoint = "/farmersmarkets/mobile/mobile.svc/locSearch?"

    // USDA farmers market detail API endpoint
    static let kUSDAFarmersMarketDetailEndpoint = "/farmersmarkets/v1/data.svc/mktDetail?"

    // SnapFresh timeout interval
    static let kSnapFreshTimeout: NSTimeInterval = 10.0

    // Animation duration
    static let kAnimationDuration: NSTimeInterval = 0.5

    // Edge insets
    static let kEdgeInsetPhone: CGFloat = 40.0
    static let kEdgeInsetPad: CGFloat = 100.0

    // Map image name
    static let kMapImageName = "103-map"

    // List image name
    static let kListImageName = "259-list"

    // Notifications posted when responses are returned
    static let kSNAPRetailersDidLoadNotification = "SNAPRetailersDidLoadNotification"
    static let kSNAPRetailersDidNotLoadNotification = "SNAPRetailersDidNotLoadNotification"
    static let kFarmersMarketsDidLoadNotification = "FarmersMarketsDidLoadNotification"
    static let kFarmersMarketsDidNotLoadNotification = "FarmersMarketsDidNotLoadNotification"
}
