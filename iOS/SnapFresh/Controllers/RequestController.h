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

#import <MapKit/MapKit.h>

@protocol RequestControllerDelegate;

@interface RequestController : NSObject <RKRequestDelegate>

/**
 * Send a SNAP retailer request for a coordinate
 *
 @param coordinate around which SNAP retailers should be located
 */
- (void)sendRequestForCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, weak) id <RequestControllerDelegate> delegate;

@end

/**
 * A delegate implements this protocol to be notified when the request is finished loading.
 */
@protocol RequestControllerDelegate
- (void)snapRetailersDidLoad:(NSArray *)snapRetailers;
- (void)snapRetailersDidNotLoadWithError:(NSError *)error;
@end
