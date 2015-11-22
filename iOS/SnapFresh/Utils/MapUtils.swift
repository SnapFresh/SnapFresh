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

import MapKit

/*!
@class MapUtils
@abstract
Map view utility class
*/
class MapUtils {
    /*!
     * @abstract calculates region to fit map annotations
     *
     * @param array of <MKAnnotation> objects
     * @returns MKMapRect which fits map annotations
     */
    class func regionToFitMapAnnotations(annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = pointRect
            }
            else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
        }

        return zoomRect
    }

    /*!
     * @abstract opens the Map app with the destination placemark
     *
     * @param destination placemark
     */
    class func openMapWithDestination(placemark: MKPlacemark) {
        let destination =  MKMapItem(placemark: placemark)
        destination.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
    }

}
