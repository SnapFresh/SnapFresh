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

@import MapKit;

/**
 * Map view utility class.
 */
@interface MapUtils : NSObject

- (instancetype)init __attribute__((unavailable("init not available")));

/**
 @param array of <MKAnnotation> objects
 @returns MKMapRect which fits map annotations
 */
+ (MKMapRect)regionToFitMapAnnotations:(NSArray *)annotations;

/**
 @param destination placemark
 */
+ (void)openMapWithDestination:(MKPlacemark *)placemark;

@end
