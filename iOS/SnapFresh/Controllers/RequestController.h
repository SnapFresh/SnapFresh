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

@import CoreLocation;

// The following notifications will be posted when responses have finished loading.
extern NSString * const kSNAPRetailersDidLoadNotification;
extern NSString * const kSNAPRetailersDidNotLoadNotification;
extern NSString * const kFarmersMarketsDidLoadNotification;
extern NSString * const kFarmersMarketsDidNotLoadNotification;

/*!
 @class RequestController
 @abstract
 A RequestController creates and sends the request
 for SNAP retailers and parses the response.
 */
@interface RequestController : NSObject

/*
 * Send a SNAP retailer request for a coordinate
 *
 @param coordinate around which SNAP retailers should be located
 */
- (void)sendSNAPRequestForCoordinate:(CLLocationCoordinate2D)coordinate;

/*
 * Send a USDA farmers market request for a coordinate
 *
 @param coordinate around which farmers markets should be located
 */
- (void)sendFarmersMarketRequestForCoordinate:(CLLocationCoordinate2D)coordinate;

@end
